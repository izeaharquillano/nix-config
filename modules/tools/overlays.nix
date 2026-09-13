# Overlay + reusable module exports (were `overlays.default` and
# `nixosModules.default` in `outputs/default.nix`).
{ inputs, self, ... }:
{
  flake.overlays.default = import ../../overlays;

  flake.nixosModules.default =
    { lib, ... }:
    {
      imports = [
        self.modules.nixos.desktop
        self.modules.nixos.features
      ];

      config = {
        nixpkgs.overlays = [
          self.overlays.default
          inputs.nix-alien.overlays.default
        ];

        mySystem.username = lib.mkDefault self.lib.vars.username;
        mySystem.kernelPackage = lib.mkDefault inputs.nixpkgs.linuxPackages_latest;
      };
    };
}
