# Single `import nixpkgs` for all `perSystem` consumers (formatter, checks,
# devShell, packages): allowUnfree + repo overlays. System modules get the
# same overlays via the host factories (`dendritic/lib.nix`) and
# `nixosModules.default` — do not re-import nixpkgs elsewhere with
# `legacyPackages`.
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
