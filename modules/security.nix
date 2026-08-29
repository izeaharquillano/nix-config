{ pkgs, ... }:

{
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      22000 # syncthing sync
      8384  # syncthing gui
    ];
    allowedUDPPorts = [
      21027 # syncthing discovery
      22000 # syncthing sync
      51820 # netbird wireguard
    ];
  };

  programs = {
    bash.shellAliases = {
      svim = "sudoedit";
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    nix-ld.enable = true;
  };
}
