{ config, mylib, ... }:

{
  imports = mylib.scanPaths ./.;

  home.stateVersion = "26.05";
  home.username = "ize";
  home.homeDirectory = "/home/${config.home.username}";
}
