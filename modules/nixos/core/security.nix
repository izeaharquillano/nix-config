{ pkgs, ... }:

{
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    nix-ld.enable = true;
  };
}
