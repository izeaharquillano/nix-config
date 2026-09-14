# Headless home (no GUI).
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.home-linux-core = {
    imports = [
      hm.user-ize
      hm.home-core-shell
      hm.home-core-cli
      hm.home-core-dev
      hm.home-core-terminal
      hm.home-core-nvim
      hm.home-core-notes
      hm.home-linux-desktop
      hm.home-linux-utils
    ];
  };
}
