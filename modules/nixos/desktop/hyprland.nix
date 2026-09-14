# Simple Aspect: Hyprland compositor + portals (drop import for Niri-only).
# Dendritic module: flake.modules.nixos.desktop-hyprland
{
  flake.modules.nixos.desktop-hyprland =
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
