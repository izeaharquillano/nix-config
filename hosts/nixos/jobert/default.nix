{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.default
    ./disko.nix
    ../../../modules/nixos/desktop.nix
    ../../../modules/features
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./host-settings.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "jobert";

  features = {
    btrfs.enable = true;
    impermanence.enable = true;
    secureboot.enable = true;
    zswap.enable = true;
    p2p = {
      enable = true;
      zerotier = {
        enable = true;
        networkId = "88c5b1f339f6593b";
      };
    };
    vm.enable = true;
    gaming.enable = true;
    containers.enable = true;
    fhs.enable = true;
    recording.enable = true;
  };

  system.stateVersion = "26.05";
}
