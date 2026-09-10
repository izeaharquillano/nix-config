{ ... }:

{
  xdg.configFile."hypr" = {
    source = ../../../config/hypr;
    recursive = true;
  };

  wayland.windowManager.hyprland.systemd.enable = false;
}
