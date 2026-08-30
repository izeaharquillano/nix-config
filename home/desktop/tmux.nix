{ config, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  xdg.configFile."tmux/tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/tmux/tmux.conf";
}
