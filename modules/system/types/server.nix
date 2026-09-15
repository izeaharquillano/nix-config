# Headless server type (no desktop, no HM).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.server = {
    imports = [
      nixos.nix
      nixos.direnv
      nixos.system
      nixos.locale
      nixos.ssh
      nixos.secrets
      nixos.security
      nixos.packages
    ];
  };
}
