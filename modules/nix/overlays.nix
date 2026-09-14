# Overlay exports; `nixosModules.default` is overlays-only for external consumers.
{ self, ... }:
{
  flake.overlays.default = import ../../overlays;

  flake.nixosModules.default = {
    nixpkgs.overlays = self.lib.sharedOverlays;
  };
}
