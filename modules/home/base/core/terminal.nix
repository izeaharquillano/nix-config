# Simple Aspect: kitty terminal
# Dendritic module: flake.modules.homeManager.home-core-terminal
{
  flake.modules.homeManager.home-core-terminal =
    { pkgs, flakeRoot, ... }:

    {
      home.packages = with pkgs; [
        kitty
      ];

      xdg.configFile."kitty/kitty.conf".source = flakeRoot + /config/kitty/kitty.conf;
    };
}
