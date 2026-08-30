{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/hypr";
}
