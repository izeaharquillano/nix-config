# Per-system `pkgs` for dev shells/checks/packages (allowUnfree + `sharedOverlays`).
# Target systems configure their own `nixpkgs` via factories (`baseSystemModules`)
# + `system/nix.nix` (`nixpkgs.config.allowUnfree`); this import is intentionally
# separate and only affects `perSystem` outputs.
{ inputs, self, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = self.lib.sharedOverlays;
      };
    };
}
