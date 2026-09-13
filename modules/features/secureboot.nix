# Conditional Aspect: UEFI Secure Boot via Lanzaboote
# Dendritic module: flake.modules.nixos.secureboot
{
  flake.modules.nixos.secureboot =
    {
      pkgs,
      lib,
      inputs,
      config,
      ...
    }:

    let
      cfg = config.features.secureboot;
    in
    {
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ];

      options.features.secureboot = {
        enable = lib.mkEnableOption "UEFI Secure Boot via Lanzaboote";
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          pkgs.sbctl
        ];

        boot.loader.systemd-boot.enable = lib.mkForce false;

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          configurationLimit = 5;
        };
      };
    };
}
