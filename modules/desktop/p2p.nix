{ pkgs, lib, config, ... }:

let
  devicesFile = ./syncthing-devices.nix;
  hasDevices = builtins.pathExists devicesFile;
  devices = if hasDevices then import devicesFile else {};
in
{
  services.syncthing = lib.mkIf hasDevices {
    enable = true;
    openDefaultPorts = true;
    user = "ize";
    dataDir = "/home/ize/Documents";
    configDir = "/home/ize/.config/syncthing";
    settings = {
      inherit devices;
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
}
