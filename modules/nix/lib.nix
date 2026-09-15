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
    # Shared Syncthing peer (don't paste the ID per host).
    syncthingServerName = "Server";
    syncthingServerId = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA";
    # Must match the Syncthing folder path (`nixos.p2p`) and vault target (`notes`).
    obsidianVaultRel = "Documents/obsidian";
    # Pinned per manuals; do NOT bump on update.
    stateVersion = "26.05";
  };

  inherit (vars) username;

  # Also feeds impermanence `rollbackDevice`; renaming one side bricks rollback.
  diskoCryptName = "cryptroot";

  # Used by host configs and perSystem pkgs.
  sharedOverlays = [
    self.overlays.default
    inputs.nix-alien.overlays.default
  ];

  # Shared by every NixOS/HM eval. No `hostname` (unused); `inputs` is for
  # external modules. Mirrored as HM `extraSpecialArgs` — keep in sync.
  specialArgs = {
    inherit inputs username vars;
    flakeRoot = self;
  };
in
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib =
    let
      mkNixosHost =
        hostname: system:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          # Loads only the host root; disko/overlays/hostname/HM binding are per-host.
          modules = [
            self.modules.nixos.${hostname}
          ];
        };
    in
    {
      inherit
        vars
        sharedOverlays
        specialArgs
        diskoCryptName
        mkNixosHost
        ;

      # Alias: "headless" just means the host binds no HM user.
      mkNixosServerHost = mkNixosHost;

      # One more compositor file = edit here, not N `home.nix` files.
      mkHostConfigFiles = dir: {
        "niri/niri-host-settings.kdl".source = dir + /niri-host-settings.kdl;
        "hypr/hypr-host-settings.lua".source = dir + /hypr-host-settings.lua;
        "noctalia/host-settings.toml".source = dir + /noctalia-host-settings.toml;
      };

      # Wipes the disk (`diskName` is immutable once formatted).
      # Deploy: `disko --mode destroy,format,mount --flake .#<host>`
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
                    # `100%` = remainder; keep last so dual-boot keeps its reservation.
                    priority = 400;
                    size = "100%";
                    content = {
                      type = "luks";
                      name = diskoCryptName;
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

      mkDarwinHost =
        hostname: system:
        inputs.nix-darwin.lib.darwinSystem {
          inherit system specialArgs;
          # Darwin hosts compose agenix/home-manager/overlays/hostname explicitly.
          modules = [
            self.modules.darwin.${hostname}
          ];
        };
    };
}
