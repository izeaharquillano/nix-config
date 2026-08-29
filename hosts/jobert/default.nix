{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/core
    ../../modules/desktop
    ../../modules/security.nix
    ../../modules/btrfs.nix
    ../../modules/secureboot.nix
    ../../modules/vm.nix
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "jobert";

  system.stateVersion = "26.05";
}
