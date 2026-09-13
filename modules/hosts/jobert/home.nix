# Dendritic home composition root for jobert.
# `inputs` inside the home module below is the runtime `extraSpecialArgs`
# (provides `niri`, `noctalia`, ...); dendritic siblings are captured via `hm`.
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.jobert =
    { inputs, ... }:
    {
      imports = [
        hm.home-linux-gui
        hm.home-features
        hm.jobert-home-packages
        inputs.niri.homeModules.niri
        inputs.noctalia.homeModules.default
      ];

      xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;
      xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
    };
}
