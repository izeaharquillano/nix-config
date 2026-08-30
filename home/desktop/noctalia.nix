{
  config,
  hostname,
  ...
}:

let
  hostSettingsFile = ../hosts/${hostname}/config/noctalia-host-settings.toml;
  hostSettings =
    if builtins.pathExists hostSettingsFile then builtins.readFile hostSettingsFile else "";
in
{
  programs.noctalia.enable = true;

  xdg.configFile."noctalia/config.toml".source = ../../config/noctalia/config.toml;
  xdg.configFile."noctalia/wallpapers".source = ../../_img/wallpapers;

  xdg.configFile."noctalia/wallpaper.toml".text =
    let
      wp = "${config.home.homeDirectory}/.config/noctalia/wallpapers/gruv-abstract-maze.png";
    in
    ''
      [wallpaper.default]
      path = "${wp}"

      [wallpaper.last]
      path = "${wp}"

      [wallpaper.monitors.eDP-1]
      path = "${wp}"
    '';

  xdg.configFile."noctalia/host-settings.toml".text = hostSettings;
}
