# Universal base shared by `desktop` and `server` (no desktop, no HM).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.core = {
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
