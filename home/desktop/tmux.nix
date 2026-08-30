{ config, repoRoot, ... }:

{
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${repoRoot}/config/tmux/tmux.conf";
}
