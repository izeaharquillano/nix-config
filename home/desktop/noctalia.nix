{ config, hostname, ... }:

let
  hostSettingsFile = ../hosts/${hostname}/config/noctalia-host-settings.toml;
  hostSettings = if builtins.pathExists hostSettingsFile then builtins.readFile hostSettingsFile else "";
in
{
  programs.noctalia = {
    enable = true;
    settings = { };
  };

  xdg.configFile."noctalia/config.toml".source = ../../config/noctalia/config.toml;
  xdg.configFile."noctalia/wallpapers".source = ../../_img/wallpapers;

  xdg.configFile."noctalia/wallpaper.toml".text = ''
    [wallpaper.default]
    path = "${config.home.homeDirectory}/.config/noctalia/wallpapers/gruv-abstract-maze.png"

    [wallpaper.last]
    path = "${config.home.homeDirectory}/.config/noctalia/wallpapers/gruv-abstract-maze.png"

    [wallpaper.monitors.eDP-1]
    path = "${config.home.homeDirectory}/.config/noctalia/wallpapers/gruv-abstract-maze.png"
  '';

  xdg.configFile."noctalia/host-settings.toml".text = hostSettings;
}
