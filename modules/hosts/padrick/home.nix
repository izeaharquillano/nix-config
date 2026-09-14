# Dendritic home composition root for padrick.
# `inputs` inside the home module below is the runtime `extraSpecialArgs`
# (provides `niri`, `noctalia`, ...); dendritic siblings are captured via `hm`.
# Importing a module IS enabling it — no feature flags.
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.padrick =
    { inputs, ... }:
    {
      imports = [
        hm.home-linux-gui
        hm.home-features-vscode
        hm.home-features-p2p
        hm.padrick-home-packages
        inputs.niri.homeModules.niri
        inputs.noctalia.homeModules.default
      ];

      xdg.configFile = {
        "niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
        "hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
        "noctalia/host-settings.toml".source = ./config/noctalia-host-settings.toml;
      };
    };
}
