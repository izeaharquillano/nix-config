# Niri compositor + Wayland env.
{
  flake.modules.nixos.desktop-niri = {
    programs.niri.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
