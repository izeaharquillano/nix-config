# Simple Aspect: Noctalia shell + wallpaper + host settings
# Dendritic module: flake.modules.homeManager.home-gui-noctalia
{
  flake.modules.homeManager.home-gui-noctalia =
    {
      config,
      hostname,
      flakeRoot,
      ...
    }:

    let
      hostSettingsPath = flakeRoot + "/modules/hosts/${hostname}/config/noctalia-host-settings.toml";
      hostSettings =
        if builtins.pathExists hostSettingsPath then builtins.readFile hostSettingsPath else "";
    in
    {
      programs.noctalia.enable = true;

      xdg.configFile."noctalia/config.toml".source = flakeRoot + /config/noctalia/config.toml;
      xdg.configFile."noctalia/wallpapers".source = flakeRoot + /_img/wallpapers;

      xdg.configFile."noctalia/wallpaper.toml".text =
        let
          wp = "${config.home.homeDirectory}/.config/noctalia/wallpapers/gruv-abstract-maze.png";
        in
        ''
          [wallpaper.default]
          path = "${wp}"

          [wallpaper.last]
          path = "${wp}"
        '';

      xdg.configFile."noctalia/host-settings.toml".text = hostSettings;
    };
}
