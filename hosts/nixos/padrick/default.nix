# padrick: ThinkPad T14 AMD Gen1 — dual-boot with Windows on the same disk.
# Disko manages disk layout; impermanence wipes root on boot.
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
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
  ];

  networking.hostName = "padrick";

  features = {
    btrfs.enable = true;
    impermanence.enable = true;
    secureboot.enable = true;
    zswap.enable = true;
    p2p.enable = true;
    containers.enable = true;
    editors.enable = true;
    fhs.enable = true;
    vm = {
      enable = true;
      dosbox.enable = true;
    };
  };

  system.stateVersion = "26.05";
}
