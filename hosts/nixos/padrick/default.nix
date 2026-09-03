{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ../../../modules/nixos/core
    ../../../modules/nixos/desktop
    ../../../modules/nixos/features
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./host-settings.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
  ];

  networking.hostName = "padrick";

  sysfeatures = {
    btrfs.enable = true;
    secureboot.enable = true;
    zswap.enable = true;
    p2p.enable = true;
    docker.enable = true;
    vm.enable = true;
  };

  system.stateVersion = "26.05";
}
