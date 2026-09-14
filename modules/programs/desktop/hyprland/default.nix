# Hyprland feature (dendritic feature closure): system compositor + HM config live together.
# Was split as `nixos/desktop/hyprland.nix` (desktop-hyprland) +
# `home/linux/gui/hyprland.nix` (home-gui-hyprland) — now one domain dir.
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
