{
  pkgs,
  lib,
  config,
  flakeRoot,
  ...
}:

let
  cfg = config.myfeatures.p2p;
in
{
  options.myfeatures.p2p = {
    enable = lib.mkEnableOption "P2P services (netbird, syncthing)";
  };

  config = lib.mkIf cfg.enable {
    age.secrets.netbird-setup-key = {
      file = "${flakeRoot}/secrets/netbird-setup-key.age";
      owner = "root";
      group = "root";
      mode = "0400";
    };

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "ize";
      dataDir = "${config.users.users.ize.home}/Documents";
      configDir = "${config.users.users.ize.home}/.config/syncthing";
      settings = {
        devices = {
          "Server".id = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA";
        };
        folders = {
          "Obsidian" = {
            path = "${config.users.users.ize.home}/Documents/obsidian";
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
  };
}
