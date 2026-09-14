# Overlay + reusable module exports (were `overlays.default` and
# `nixosModules.default` in `outputs/default.nix`).
{ inputs, self, ... }:
{
  flake.overlays.default = import ../../overlays;

  # Central nixpkgs wiring for perSystem consumers lives in
  # `modules/tools/nixpkgs.nix` (single `import nixpkgs` with overlays +
  # allowUnfree). System modules get overlays via the host factories +
  # this reusable module.
  flake.nixosModules.default =
    { ... }:
    {
      imports = [
        self.modules.nixos.desktop
      ];

      config = {
        nixpkgs.overlays = [
          self.overlays.default
          inputs.nix-alien.overlays.default
        ];
      };
    };
}
