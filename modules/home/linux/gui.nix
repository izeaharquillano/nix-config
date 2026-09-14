# Full GUI home; hosts add `home-features-*` as needed.
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.home-linux-gui = {
    imports = [
      hm.home-linux-core
      hm.home-gui-apps
      hm.home-gui-web
      hm.home-gui-hyprland
      hm.home-gui-niri
      hm.home-gui-noctalia
    ];
  };
}
