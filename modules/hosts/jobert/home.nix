# Niri/Noctalia HM modules come via `home-linux-gui`.
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.jobert =
    { pkgs, ... }:
    {
      imports = [
        hm.home-linux-gui
        hm.home-features-vscode
        hm.home-features-recording
        hm.home-features-p2p
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
