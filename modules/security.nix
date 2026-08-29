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
    ];
    allowedUDPPorts = [
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
