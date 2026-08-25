{ config, ... }:

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
}
