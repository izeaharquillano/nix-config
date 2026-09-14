# Single `import nixpkgs` (allowUnfree + overlays) for `perSystem` consumers.
# System modules get overlays via host factories; no `legacyPackages` elsewhere.
{ inputs, self, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          self.overlays.default
          inputs.nix-alien.overlays.default
        ];
      };
    };
}
