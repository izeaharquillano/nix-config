{ config, pkgs, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  home.packages = with pkgs; [
    kitty
  ];

  xdg.configFile."kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/kitty/kitty.conf";
}
