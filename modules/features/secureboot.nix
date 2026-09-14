# Simple Aspect: UEFI Secure Boot via Lanzaboote.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.secureboot
{ inputs, ... }:
{
  flake.modules.nixos.secureboot =
    {
      pkgs,
      lib,
      ...
    }:

    {
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ];

      environment.systemPackages = [
        pkgs.sbctl
      ];

      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = 5;
        # Auto-generates keys on first boot; nixos-install works keyless.
        autoGenerateKeys.enable = true;
        # Enrollment stays manual: `sbctl enroll-keys --microsoft`.
      };

      # Keys persist via impermanence.nix (`/var/lib` + `/var/lib/sbctl`).
    };
}
