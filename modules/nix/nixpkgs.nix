# perSystem `pkgs` (free-only by design; the unfree opt-in lives in
# `system/nix.nix` and covers targets only).
{ inputs, self, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = self.lib.sharedOverlays;
      };
    };
}
