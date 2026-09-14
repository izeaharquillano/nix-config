# Raw KDL config (managed in `config/niri/`); no `programs.niri` HM options used.
{
  flake.modules.homeManager.home-gui-niri =
    { flakeRoot, ... }:
    {
      xdg.configFile."niri/config.kdl".source = flakeRoot + /config/niri/config.kdl;
    };
}
