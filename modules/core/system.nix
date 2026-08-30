{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.mySystem = {
    kernelPackage = lib.mkOption {
      type = lib.types.attrs;
      default = pkgs.linuxPackages_7_2;
      description = "Linux kernel packages set to use (e.g. pkgs.linuxPackages_7_2)";
    };
  };

  config = {
    programs.direnv.enable = true;

    boot = {
      kernelPackages = config.mySystem.kernelPackage;

      loader = {
        efi.canTouchEfiVariables = true;
        timeout = 10;
        systemd-boot.enable = true;
      };
    };

    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];
      max-jobs = "auto";
      http-connections = 50;
      auto-optimise-store = true;
      warn-dirty = false;
    };

    nix.gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    users.users."ize" = {
      isNormalUser = true;
      description = "ize";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };
}
