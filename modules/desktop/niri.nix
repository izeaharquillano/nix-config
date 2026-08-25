{ ... }:

{
  programs.niri.enable = true;

  systemd.user.services.niri.enableDefaultPath = false;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
