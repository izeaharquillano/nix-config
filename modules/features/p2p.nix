# Simple Aspect: P2P services (NetBird, Syncthing, LocalSend).
# Import this module = enabled (pure dendritic: composition decides).
# Host-specific Syncthing peers/folders stay as options (no enable flag).
# Dendritic module: flake.modules.nixos.p2p
{
  flake.modules.nixos.p2p =
    {
      pkgs,
      lib,
      flakeRoot,
      config,
      username,
      ...
    }:

    let
      homeDir = config.users.users.${username}.home;
    in
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
          default = {
            "Server".id = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA";
          };
          description = "Syncthing devices to share with.";
        };

        folders = lib.mkOption {
          type = lib.types.attrsOf lib.types.unspecified;
          default = { };
          description = "Syncthing folders (merged with the default Obsidian folder below).";
        };
      };

      config = {
        age.secrets.netbird-setup-key = {
          file = "${flakeRoot}/secrets/netbird-setup-key.age";
          owner = "root";
          group = "root";
          mode = "0400";
        }
        // lib.optionalAttrs (config.environment.persistence ? "/persist") {
          # Impermanence hosts decrypt to persistent storage instead of /run.
          path = "/persist/secrets/netbird-setup-key";
          symlink = false;
        };

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
            folders = {
              "Obsidian" = {
                path = "${homeDir}/Documents/obsidian";
                devices = [ "Server" ];
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
