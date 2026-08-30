{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/nvim";
}
