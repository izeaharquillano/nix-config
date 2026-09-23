# Desktop core + HM wiring. Compositors and greetd stay per-host, not collected here.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.desktop = {
    imports = [
      nixos.core
      nixos.desktop-services
      nixos.home-manager
    ];
  };
}
