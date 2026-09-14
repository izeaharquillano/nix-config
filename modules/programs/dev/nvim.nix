{
  flake.modules.homeManager.nvim =
    { flakeRoot, ... }:

    {
      xdg.configFile."nvim" = {
        source = flakeRoot + /config/nvim;
        recursive = true;
      };
    };
}
