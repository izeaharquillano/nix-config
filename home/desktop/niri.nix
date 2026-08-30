{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/niri/config.kdl";
}
