{ config, repoRoot, ... }:

{
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${repoRoot}/config/niri/config.kdl";
}
