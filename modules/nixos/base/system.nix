# Simple Aspect: boot, networking, GC
# Dendritic module: flake.modules.nixos.base-system
# NOTE: no `mySystem.username` option; identity comes from the `username`
# specialArg, account lives in `users/ize.nix`.
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

        # Account defined in `users/ize.nix`.
      };
    };
}
