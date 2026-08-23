{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/core
    ../../modules/desktop
    ../../modules/security.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "padrick";

  system.stateVersion = "26.05";
}
