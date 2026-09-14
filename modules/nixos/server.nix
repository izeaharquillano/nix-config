# Headless server type (no desktop, no HM; disko stays per-host).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.server = {
    imports = [
      nixos.base-nix
      nixos.base-direnv
      nixos.base-system
      nixos.base-locale
      nixos.base-ssh
      nixos.base-secrets
      nixos.base-security
      nixos.base-packages
    ];
  };
}
