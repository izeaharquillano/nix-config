{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

let
  cfg = config.sysfeatures.secureboot;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options.sysfeatures.secureboot = {
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
}
