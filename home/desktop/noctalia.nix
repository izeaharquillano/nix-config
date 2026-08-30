{ config, hostname, repoRoot, ... }:

let
  hostSettingsFile = ../hosts/${hostname}/config/noctalia-host-settings.toml;
  hostSettings =
    if builtins.pathExists hostSettingsFile then builtins.readFile hostSettingsFile else "";
in
{
  programs.noctalia.enable = true;

  xdg.configFile."noctalia/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/config/noctalia/config.toml";
  xdg.configFile."noctalia/wallpapers".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/_img/wallpapers";

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
