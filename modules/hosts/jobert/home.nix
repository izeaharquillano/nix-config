# Niri/Noctalia HM modules come via `linux-gui`.
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.jobert =
    { pkgs, ... }:
    {
      imports = [
        hm.linux-gui
        hm.vscode
        hm.recording
        hm.p2p
      ];

      home.packages = [
        pkgs.btop-cuda
        pkgs.chromium
        pkgs.prismlauncher
      ];

      xdg.configFile = {
        "niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
        "hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
        "noctalia/host-settings.toml".source = ./config/noctalia-host-settings.toml;
      };
    };
}
