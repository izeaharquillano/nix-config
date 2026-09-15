# Full GUI home type. Compositors stay per-host, not collected here.
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
      hm.noctalia
      hm.notes
    ];
  };
}
