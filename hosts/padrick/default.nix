{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/core
    ../../modules/desktop
    ../../modules/security.nix
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
  ];

  networking.hostName = "padrick";

  system.stateVersion = "26.05";
}
