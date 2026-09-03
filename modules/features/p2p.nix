{
  pkgs,
  lib,
  config,
  flakeRoot,
  ...
}:

let
  cfg = config.features.p2p;
in
{
  options.features.p2p = {
    enable = lib.mkEnableOption "P2P services (netbird, syncthing, localsend)";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ 51820 ];

    age.secrets.netbird-setup-key = {
      file = "${flakeRoot}/secrets/netbird-setup-key.age";
      owner = "root";
      group = "root";
      mode = "0400";
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

    services.netbird = {
      enable = true;

      clients.default = {
        port = 51820;
        ui.enable = true;

        login = {
          enable = true;
          setupKeyFile = config.age.secrets.netbird-setup-key.path;
        };

        openFirewall = true;
        openInternalFirewall = true;
      };
    };

    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}
