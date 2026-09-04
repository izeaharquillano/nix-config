{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ../../../modules/nixos/desktop.nix
    ../../../modules/features
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
    ./host-settings.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
  ];

  networking.hostName = "padrick";

  features = {
    btrfs.enable = true;
    secureboot.enable = true;
    zswap.enable = true;
    p2p.enable = true;
    containers.enable = true;
    vm.enable = true;
    editors.enable = true;
    fhs.enable = true;
  };

  system.stateVersion = "26.05";
}
