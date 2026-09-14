# Niri feature (dendritic feature closure): system compositor + HM config live together.
# Was split as `nixos/desktop/niri.nix` (desktop-niri) +
# `home/linux/gui/niri.nix` (home-gui-niri) — now one domain dir.
{
  flake.modules.homeManager.niri =
    { flakeRoot, ... }:
    {
      xdg.configFile."niri/config.kdl".source = flakeRoot + /config/niri/config.kdl;
    };

  flake.modules.nixos.niri = {
    programs.niri.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
