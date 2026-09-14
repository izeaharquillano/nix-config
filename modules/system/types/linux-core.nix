# Headless home system type (Inheritance Aspect); GUI pieces live in `linux-gui` only.
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.linux-core = {
    imports = [
      hm.user-ize
      hm.shell
      hm.cli
      hm.dev
      hm.terminal
      hm.nvim
    ];
  };
}
