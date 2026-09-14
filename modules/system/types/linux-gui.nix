# Full GUI home system type (Inheritance Aspect); hosts add `vscode`/`recording`/`p2p` as needed.
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.linux-gui = {
    imports = [
      hm.linux-core
      hm.linux-desktop
      hm.linux-utils
      hm.apps
      hm.web
      hm.hyprland
      hm.niri
      hm.noctalia
      hm.notes
    ];
  };
}
