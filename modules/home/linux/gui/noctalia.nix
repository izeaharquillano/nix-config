# Simple Aspect: Noctalia shell + wallpaper.
# Per-host `host-settings.toml` comes from each host's `home.nix`.
# Dendritic module: flake.modules.homeManager.home-gui-noctalia
{
  flake.modules.homeManager.home-gui-noctalia =
    { config, flakeRoot, ... }:

    {
      programs.noctalia.enable = true;

      xdg.configFile = {
        "noctalia/config.toml".source = flakeRoot + /config/noctalia/config.toml;
        "noctalia/wallpapers".source = flakeRoot + /_img/wallpapers;

        "noctalia/wallpaper.toml".text =
          let
            wp = "${config.home.homeDirectory}/.config/noctalia/wallpapers/gruv-abstract-maze.png";
          in
          ''
            [wallpaper.default]
            path = "${wp}"

            [wallpaper.last]
            path = "${wp}"
          '';
      };
    };
}
