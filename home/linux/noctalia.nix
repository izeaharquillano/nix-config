{
  config,
  hostname,
  ...
}:

let
  hostSettings = builtins.readFile (../hosts/nixos/${hostname}/config/noctalia-host-settings.toml);
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
    '';

  xdg.configFile."noctalia/host-settings.toml".text = hostSettings;
}
