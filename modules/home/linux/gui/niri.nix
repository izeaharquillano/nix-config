{ inputs, ... }:
{
  flake.modules.homeManager.home-gui-niri =
    { flakeRoot, ... }:
    {
      imports = [
        inputs.niri.homeModules.niri
      ];

      xdg.configFile."niri/config.kdl".source = flakeRoot + /config/niri/config.kdl;
    };
}
