# Conditional Aspect: NetBird, Syncthing, LocalSend, ZeroTier
# Dendritic module: flake.modules.nixos.p2p
{
  flake.modules.nixos.p2p =
    {
      pkgs,
      lib,
      flakeRoot,
      config,
      ...
    }:

    let
      cfg = config.features.p2p;
      mkEnabledOption = desc: lib.mkEnableOption desc // { default = true; };
    in
    {
      options.features.p2p = {
        enable = lib.mkEnableOption "P2P services (netbird, syncthing, localsend)";
        netbird.enable = mkEnabledOption "Netbird for remote access to server";
        syncthing.enable = mkEnabledOption "Syncthing for file syncing across devices";
        localsend.enable = mkEnabledOption "Localsend for sending files across devices";
        zerotier = {
          enable = lib.mkEnableOption "ZeroTier networking";
          networkId = lib.mkOption {
            type = lib.types.str;
            example = "8056c2e21c123456";
            description = "ZeroTier network ID to join on startup";
          };
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [

          (lib.mkIf cfg.netbird.enable {
            age.secrets.netbird-setup-key = {
              file = "${flakeRoot}/secrets/netbird-setup-key.age";
              owner = "root";
              group = "root";
              mode = "0400";
            }
            // lib.optionalAttrs config.features.impermanence.enable {
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
          })

          (lib.mkIf cfg.syncthing.enable {
            services.syncthing = {
              enable = true;
              openDefaultPorts = true;
              user = config.mySystem.username;
              dataDir = "${config.users.users.${config.mySystem.username}.home}/Documents";
              configDir = "${config.users.users.${config.mySystem.username}.home}/.config/syncthing";
              settings = {
                devices = {
                  "Server".id = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA";
                };
                folders = {
                  "Obsidian" = {
                    path = "${config.users.users.${config.mySystem.username}.home}/Documents/obsidian";
                    devices = [ "Server" ];
                  };
                };
              };
            };
          })

          (lib.mkIf cfg.localsend.enable {
            programs.localsend = {
              enable = true;
              openFirewall = true;
            };
          })

          (lib.mkIf cfg.zerotier.enable {
            networking.firewall.allowedUDPPorts = [ 9993 ];
            services.zerotierone = {
              enable = true;
              joinNetworks = [ cfg.zerotier.networkId ];
            };
          })

        ]
      );
    };
}
