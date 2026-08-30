{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/starship.toml";
}
