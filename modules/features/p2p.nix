# Simple Aspect: P2P services (NetBird, Syncthing, LocalSend).
# Import this module = enabled (pure dendritic: composition decides).
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

    {
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

      programs.localsend = {
        enable = true;
        openFirewall = true;
      };
    };
}
