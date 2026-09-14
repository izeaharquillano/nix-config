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
