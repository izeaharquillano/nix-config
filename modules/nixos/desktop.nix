# Inheritance Aspect: the desktop system type composes cross-platform base,
# NixOS base, and desktop environments. Hosts import this instead of
# hand-picking modules.
# Dendritic module: flake.modules.nixos.desktop
{ inputs, ... }:
{
  flake.modules.nixos.desktop = {
    imports = [
      inputs.disko.nixosModules.default
    ]
    ++ (with inputs.self.modules.nixos; [
      base-nix
      base-direnv
      base-system
      base-locale
      base-ssh
      base-secrets
      base-security
      base-packages
      desktop-greetd
      desktop-niri
      desktop-services
      home-manager
    ]);
  };
}
