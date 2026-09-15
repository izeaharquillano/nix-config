# Niri compositor + HM config.
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
