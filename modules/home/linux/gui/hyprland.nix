# Simple Aspect: Hyprland dotfiles (recursive)
# Dendritic module: flake.modules.homeManager.home-gui-hyprland
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
