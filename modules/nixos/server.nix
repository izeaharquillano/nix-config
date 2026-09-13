# Inheritance Aspect: the headless server system type. No desktop modules,
# no Home Manager (see `mkNixosServerHost` in `dendritic/lib.nix`).
# Dendritic module: flake.modules.nixos.server
{ inputs, ... }:
{
  flake.modules.nixos.server = {
    imports = with inputs.self.modules.nixos; [
      base-nix
      base-direnv
      base-system
      base-locale
      base-ssh
      base-secrets
      base-security
      base-packages
    ];
  };
}
