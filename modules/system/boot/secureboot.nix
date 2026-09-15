# Secure Boot via Lanzaboote (keys in /var/lib/sbctl, kept by impermanence).
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
          # `or {}`: clean assertion failure instead of a missing-attr error.
          assertion = (config.environment.persistence or { }) ? "/persist";
          message = "nixos.secureboot requires nixos.impermanence (/var/lib persistence for /var/lib/sbctl keys).";
        }
      ];

      environment.systemPackages = [
        pkgs.sbctl
      ];

      # Base is `mkDefault true`, so plain `false` wins without `mkForce`.
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
