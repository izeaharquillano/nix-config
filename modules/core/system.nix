{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

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
}
