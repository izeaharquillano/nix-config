# Simple Aspect: boot, networking, GC
# Dendritic module: flake.modules.nixos.base-system
# NOTE: primary user identity comes from the `username` specialArg
# (`flake.lib.vars.username`); there is deliberately no `mySystem.username`
# option. The account itself lives in `users/ize.nix`.
{
  flake.modules.nixos.base-system =
    {
      config,
      pkgs,
      lib,
      username,
      ...
    }:

    {
      options.mySystem = {
        kernelPackage = lib.mkOption {
          type = lib.types.attrs;
          default = pkgs.linuxPackages_latest;
          description = "Linux kernel packages set to use (e.g. pkgs.linuxPackages_latest)";
        };
      };

      config = {
        boot = {
          kernelPackages = config.mySystem.kernelPackage;

          loader = {
            efi.canTouchEfiVariables = true;
            timeout = 10;
            systemd-boot.enable = true;
          };
        };

        networking.networkmanager.enable = true;
        hardware.enableAllFirmware = true;

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

        systemd.services."home-manager-${username}" = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };

        # The primary user account itself is defined by the `user-ize` feature
        # (modules/users/ize.nix), which hosts import alongside this module.
      };
    };
}
