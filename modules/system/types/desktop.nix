# Desktop core + HM wiring. Compositors and greetd stay per-host, not collected here.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.desktop = {
    imports = [
      nixos.nix
      nixos.direnv
      nixos.system
      nixos.locale
      nixos.ssh
      nixos.secrets
      nixos.security
      nixos.packages
      nixos.desktop-services
      nixos.home-manager
    ];
  };
}
