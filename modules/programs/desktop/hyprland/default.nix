# Hyprland compositor + HM config.
{
  flake.modules.homeManager.hyprland =
    { flakeRoot, ... }:

    {
      xdg.configFile."hypr" = {
        source = flakeRoot + /config/hypr;
        recursive = true;
      };

      wayland.windowManager.hyprland.systemd.enable = false;
    };

  flake.modules.nixos.hyprland =
    { pkgs, ... }:

    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      xdg.portal = {
        enable = true;
        config = {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          };
          # Niri portal defaults come from `programs.niri` upstream
          # (gnome+gtk); don't override here (list-order conflict).
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-hyprland
        ];
      };
    };
}
