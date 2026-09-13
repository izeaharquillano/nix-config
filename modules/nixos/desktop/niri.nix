# Simple Aspect: Niri compositor + Wayland env
# Dendritic module: flake.modules.nixos.desktop-niri
{
  flake.modules.nixos.desktop-niri =
    { ... }:

    {
      programs.niri.enable = true;

      systemd.user.services.niri.enableDefaultPath = false;

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
    };
}
