# Boot, networking, GC (identity via `username` specialArg, see `users/ize.nix`).
{
  flake.modules.nixos.base-system =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      options.features.system = {
        kernelPackage = lib.mkOption {
          # Kernel sets are attrsets, not derivations; `unspecified` is intentional.
          type = lib.types.unspecified;
          default = pkgs.linuxPackages_latest;
          defaultText = lib.literalExpression "pkgs.linuxPackages_latest";
          example = lib.literalExpression "pkgs.linuxPackages_6_12";
          description = "Linux kernel packages set to use (e.g. pkgs.linuxPackages_latest)";
        };
      };

      config = {
        boot = {
          kernelPackages = config.features.system.kernelPackage;

          loader = {
            # mkDefault so `secureboot` (lanzaboote) can override without mkForce.
            efi.canTouchEfiVariables = lib.mkDefault true;
            timeout = lib.mkDefault 10;
            systemd-boot.enable = lib.mkDefault true;
          };
        };

        networking.networkmanager.enable = lib.mkDefault true;
        hardware.enableRedistributableFirmware = lib.mkDefault true;

        nix = {
          gc = {
            automatic = true;
            persistent = true;
            dates = [ "weekly" ];
            options = "--delete-older-than 14d";
          };

          optimise = {
            automatic = true;
            dates = [ "weekly" ];
          };
        };
      };
    };
}
