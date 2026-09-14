# Desktop system type (Inheritance Aspect): system core + desktop + HM.
# Disko stays per-host; drop `hyprland` for Niri-only.
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
      nixos.greetd
      nixos.niri
      nixos.hyprland
      nixos.desktop-services
      nixos.home-manager
    ];
  };
}
