# Host factories + shared identity/overlays.
{
  inputs,
  self,
  lib,
  ...
}:
let
  vars = {
    username = "ize";
    userfullname = "Izeah Arquillano";
    useremail = "izeaharquillano@gmail.com";
    # Shared Syncthing peer; hosts reference this instead of pasting the ID.
    syncthingServerName = "Server";
    syncthingServerId = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA";
    # Single source for Obsidian vault location; must stay in sync between
    # `nixos.p2p` (Syncthing folder path) and `notes` (vault target).
    obsidianVaultRel = "Documents/obsidian";
  };

  inherit (vars) username;

  # Canonical overlay list — consumed by host factories AND perSystem pkgs.
  sharedOverlays = [
    self.overlays.default
    inputs.nix-alien.overlays.default
  ];

  specialArgsFor = hostname: {
    inherit
      inputs
      hostname
      username
      vars
      ;
    flakeRoot = self;
  };

  baseSystemModules = hostname: [
    inputs.disko.nixosModules.default
    {
      nixpkgs.overlays = sharedOverlays;
      # Single definition of hostname; hosts may override with mkForce if needed.
      networking.hostName = lib.mkDefault hostname;
    }
  ];

  # Binds the HM user only; shared HM settings live in `tools/home-manager.nix`.
  homeManagerUsersBlock = hostname: {
    home-manager = {
      users.${username} = self.modules.homeManager.${hostname};
      extraSpecialArgs = specialArgsFor hostname;
    };
  };
in
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib = {
    inherit vars sharedOverlays;

    # Destructive disko layout; `diskName` must match format-time name or boot fails.
    # Deploy: `disko --mode destroy,format,mount --flake .#<host>`
    # NOTE: `luksExtraFormatArgs` defaults to LUKS2/argon2id (format-only).
    mkDiskoBtrfs =
      {
        diskName,
        device,
        withWindows ? false,
        windowsSize ? "122070M",
        swapSize ? "8G",
        luksExtraFormatArgs ? [
          "--type luks2"
          "--cipher aes-xts-plain64"
          "--hash sha512"
          "--iter-time 5000"
          "--key-size 256"
          "--pbkdf argon2id"
        ],
      }:
      {
        disko.devices = {
          disk.${diskName} = {
            type = "disk";
            inherit device;
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  name = "ESP";
                  start = "1M";
                  end = "1G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [
                      "fmask=0177"
                      "dmask=0077"
                      "noexec"
                      "nosuid"
                      "nodev"
                    ];
                  };
                };
                luks = {
                  # `100%` = remainder after fixed-size partitions. Keep luks
                  # last (priority 400, after Windows 290/300) so dual-boot
                  # keeps its reservation; no explicit priority = same effect
                  # but implicit ordering is fragile.
                  priority = 400;
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "cryptroot";
                    settings.allowDiscards = true;
                    initrdUnlock = true;
                    extraFormatArgs = luksExtraFormatArgs;
                    content = {
                      type = "btrfs";
                      extraArgs = [
                        "-L"
                        "nixos"
                        "-f"
                      ];
                      subvolumes = {
                        "/root" = {
                          mountpoint = "/";
                        };
                        "/home" = {
                          mountpoint = "/home";
                        };
                        "/nix" = {
                          mountpoint = "/nix";
                        };
                        "/persist" = {
                          mountpoint = "/persist";
                          mountOptions = [
                            "compress=zstd:3"
                            "noatime"
                            "ssd"
                            "discard=async"
                            "commit=120"
                          ];
                        };
                        "/swap" = {
                          mountpoint = "/swap";
                          swap.swapfile.size = swapSize;
                        };
                      };
                    };
                  };
                };
              }
              // lib.optionalAttrs withWindows {
                "Microsoft reserved" = {
                  type = "0C01";
                  priority = 290;
                  size = "16M";
                };
                "Windows data" = {
                  type = "0700";
                  priority = 300;
                  size = windowsSize;
                };
              };
            };
          };
        };
      };

    mkNixosHost =
      hostname: system:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgsFor hostname;
        modules = [
          self.modules.nixos.${hostname}
          # HM + agenix come from composition; factory binds the HM user only.
          (homeManagerUsersBlock hostname)
        ]
        ++ baseSystemModules hostname;
      };

    # Headless variant (no HM binding).
    mkNixosServerHost =
      hostname: system:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgsFor hostname;
        modules = [
          self.modules.nixos.${hostname}
        ]
        ++ baseSystemModules hostname;
      };

    mkDarwinHost =
      hostname: system:
      let
        agenixDarwin =
          if inputs.agenix ? darwinModules then
            inputs.agenix.darwinModules.age
          else
            inputs.agenix.nixosModules.age;
      in
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = specialArgsFor hostname;
        modules = [
          self.modules.darwin.${hostname}
          agenixDarwin
          inputs.home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = sharedOverlays;
            networking.hostName = lib.mkDefault hostname;
          }
          (homeManagerUsersBlock hostname)
        ];
      };
  };
}
