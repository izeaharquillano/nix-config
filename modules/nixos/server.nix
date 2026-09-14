# Inheritance Aspect: headless server system type (no desktop, no HM).
# Dendritic module: flake.modules.nixos.server
{ inputs, ... }:
{
  flake.modules.nixos.server = {
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
    ]);
  };
}
