{ ... }:

{
  programs.niri.enable = true;

  systemd.user.services.niri.enableDefaultPath = false;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
