{ pkgs, ... }:

{
  services.blueman.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "ize";
    dataDir = "/home/ize/Documents";
    configDir = "/home/ize/.config/syncthing";
    settings = {
      devices = {
        "Server" = { id = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA"; };
      };
      folders = {
        "Obsidian" = {
          path = "/home/ize/Documents/obsidian";
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
        setupKeyFile = "/etc/netbird/setup-key";
      };

      openFirewall = true;
      openInternalFirewall = true;
    };
  };

  systemd.services.netbird-login = {
    serviceConfig = {
      StandardOutput = "null";
      StandardError = "null";
      LogLevelMax = "warning";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}
