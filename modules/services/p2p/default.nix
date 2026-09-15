# P2P feature (dendritic feature closure): system daemon + HM tray live together.
# Was split as `features/p2p.nix` (nixos.p2p) + `home/base/features/p2p.nix`
# (home-features-p2p) — now one domain dir `services/p2p/`.
{
  flake.modules.homeManager.p2p = {
    services.syncthing.tray.enable = true;
  };

  flake.modules.nixos.p2p =
    {
      lib,
      flakeRoot,
      config,
      username,
      vars,
      ...
    }:
    {
      options.features.p2p.syncthing = {
        devices = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options.id = lib.mkOption {
                type = lib.types.str;
                description = "Syncthing device ID.";
              };
            }
          );
          default = { };
          example = {
            "Server".id = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA";
          };
          description = "Syncthing devices to share with. Set per-host; empty by default.";
        };

        folders = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              freeformType = lib.types.attrsOf lib.types.unspecified;
              options = {
                path = lib.mkOption {
                  type = lib.types.str;
                  description = "Folder path to sync.";
                };
                devices = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                  description = "Device names to share this folder with.";
                };
              };
            }
          );
          default = { };
          description = "Extra Syncthing folders; same key overrides the Obsidian default.";
        };

        obsidianEnable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Sync obsidian vault (must match `notes`, see `vars.obsidianVaultRel`).";
        };
      };

      config =
        let
          homeDir = config.users.users.${username}.home;
          # `or {}`: hosts without impermanence lack the option entirely.
          hasPersist = (config.environment.persistence or { }) ? "/persist";
        in
        {
          # Persisted copy bypasses agenix tmpfs (survives reboot; LUKS +
          # `0400` mitigate). Exclude `/persist/secrets` from backups.
          age.secrets.netbird-setup-key = {
            file = flakeRoot + /secrets/netbird-setup-key.age;
            owner = "root";
            group = "root";
            mode = "0400";
          }
          // lib.optionalAttrs hasPersist {
            path = "/persist/secrets/netbird-setup-key";
            symlink = false;
          };

          # Ordering vs HM lives in `nix/home-manager.nix`.
          services.netbird = {
            enable = true;
            clients.default = {
              port = 51821;
              ui.enable = true;
              login = {
                enable = true;
                setupKeyFile = config.age.secrets.netbird-setup-key.path;
              };
              openFirewall = true;
              openInternalFirewall = true;
            };
          };

          services.syncthing = {
            enable = true;
            openDefaultPorts = true;
            user = username;
            dataDir = "${homeDir}/Documents";
            configDir = "${homeDir}/.config/syncthing";
            settings = {
              devices = config.features.p2p.syncthing.devices;
              folders =
                lib.optionalAttrs config.features.p2p.syncthing.obsidianEnable {
                  "Obsidian" = {
                    path = "${homeDir}/${vars.obsidianVaultRel}";
                    devices = lib.attrNames config.features.p2p.syncthing.devices;
                  };
                }
                // config.features.p2p.syncthing.folders;
            };
          };

          programs.localsend = {
            enable = true;
            openFirewall = true;
          };
        };
    };
}
