{
  flake.modules.homeManager.home-core-terminal =
    { pkgs, flakeRoot, ... }:

    {
      home.packages = [
        pkgs.kitty
      ];

      xdg.configFile."kitty/kitty.conf".source = flakeRoot + /config/kitty/kitty.conf;
    };
}
