{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.mySystem = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Primary user username";
    };

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

    nix.gc = {
      automatic = true;
      persistent = true;
      dates = [ "weekly" ];
      options = "--delete-older-than 14d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    users.users.${config.mySystem.username} = {
      isNormalUser = true;
      description = "Primary user";
      # Set when impermanence is disabled. When enabled, hashedPasswordFile
      # in impermanence.nix takes precedence and this is ignored.
      initialPassword = lib.mkIf (!(config.features.impermanence.enable or false)) "changeme";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };
}
