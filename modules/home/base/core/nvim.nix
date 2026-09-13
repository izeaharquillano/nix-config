# Simple Aspect: Neovim config (recursive)
# Dendritic module: flake.modules.homeManager.home-core-nvim
{
  flake.modules.homeManager.home-core-nvim =
    { flakeRoot, ... }:

    {
      xdg.configFile."nvim" = {
        source = flakeRoot + /config/nvim;
        recursive = true;
      };
    };
}
