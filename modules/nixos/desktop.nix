# Desktop type: base + Niri/Hyprland + HM (disko stays per-host; drop `desktop-hyprland` for Niri-only).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.desktop = {
    imports = [
      nixos.base-nix
      nixos.base-direnv
      nixos.base-system
      nixos.base-locale
      nixos.base-ssh
      nixos.base-secrets
      nixos.base-security
      nixos.base-packages
      nixos.desktop-greetd
      nixos.desktop-niri
      nixos.desktop-hyprland
      nixos.desktop-services
      nixos.home-manager
    ];
  };
}
