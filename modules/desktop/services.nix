{ pkgs, ... }:

{
  services.blueman.enable = true;
  services.fwupd.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
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

  # systemd.services.netbird-login = {
  #   serviceConfig = {
  #     StandardOutput = "null";
  #     StandardError = "null";
  #     LogLevelMax = "warning";
  #   };
  # };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}
