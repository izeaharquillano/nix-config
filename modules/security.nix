{ pkgs, ... }:

{
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
