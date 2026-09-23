# Headless server type (no desktop, no HM).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.server = {
    imports = [
      nixos.core
    ];
  };
}
