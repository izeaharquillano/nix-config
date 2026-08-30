{ config, repoRoot, ... }:

{
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/config/starship.toml";
}
