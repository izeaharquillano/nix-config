{
  flake.modules.homeManager.home-gui-hyprland =
    { flakeRoot, ... }:

    {
      xdg.configFile."hypr" = {
        source = flakeRoot + /config/hypr;
        recursive = true;
      };

      wayland.windowManager.hyprland.systemd.enable = false;
    };
}
