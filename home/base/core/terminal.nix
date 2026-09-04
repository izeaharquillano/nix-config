{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];

  xdg.configFile."kitty/kitty.conf".source = ../../../config/kitty/kitty.conf;
}
