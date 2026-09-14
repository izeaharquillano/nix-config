# Noctalia shell; per-host settings come from each host's `home.nix`.
{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, flakeRoot, ... }:

    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

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
