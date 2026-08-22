{ pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      config = {
        user.name = "Izeah Arquillano";
        user.email = "izeaharquillano@gmail.com";
      };
    };
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
