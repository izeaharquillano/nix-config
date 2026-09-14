# Home composition root for padrick; import = enable.
# Inner `inputs` is `extraSpecialArgs`; siblings via `hm`.
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
