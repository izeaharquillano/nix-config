# Simple Aspect: Niri config file
# Dendritic module: flake.modules.homeManager.home-gui-niri
{
  flake.modules.homeManager.home-gui-niri =
    { flakeRoot, ... }:

    {
      xdg.configFile."niri/config.kdl".source = flakeRoot + /config/niri/config.kdl;
    };
}
