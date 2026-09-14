# Overlay + `nixosModules.default` exports.
{ inputs, self, ... }:
{
  flake.overlays.default = import ../../overlays;

  # Overlays via host factories + this module (`pkgs` in `tools/nixpkgs.nix`).
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
