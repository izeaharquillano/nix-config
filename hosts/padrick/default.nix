{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/core
    ../../modules/desktop
    ../../modules/security.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "padrick";

  host.monitors = [
    {
      name = "eDP-1";
      mode = "1920x1080@60";
      scale = "1.20";
      position = "auto";
    }
  ];

  system.stateVersion = "26.05";
}
