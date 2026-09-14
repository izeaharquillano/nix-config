# UEFI Secure Boot via Lanzaboote (keys under /var/lib/sbctl, persisted by impermanence).
{ inputs, ... }:
{
  flake.modules.nixos.secureboot =
    {
      pkgs,
      config,
      ...
    }:

    {
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ];

      assertions = [
        {
          # `or {}` so hosts without impermanence get a clean assertion
          # failure instead of an attribute-missing eval error.
          assertion = (config.environment.persistence or { }) ? "/persist";
          message = "nixos.secureboot requires nixos.impermanence (/var/lib persistence for /var/lib/sbctl keys).";
        }
      ];

      environment.systemPackages = [
        pkgs.sbctl
      ];

      # Base sets `mkDefault true`; plain `false` overrides without mkForce.
      boot.loader.systemd-boot.enable = false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = 5;
        autoGenerateKeys.enable = true; # keyless nixos-install
        # Enrollment stays manual: `sbctl enroll-keys --microsoft`.
      };
    };
}
