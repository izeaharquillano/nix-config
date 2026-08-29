{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/core
    ../../modules/desktop
    ../../modules/security.nix
    ../../modules/features
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "jobert";

  myfeatures = {
    btrfs.enable = true;
    secureboot.enable = true;
    vm.enable = true;
    gaming.enable = true;
  };

  system.stateVersion = "26.05";
}
