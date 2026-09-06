# padrick: ThinkPad T14 AMD Gen1 — dual-boot with Windows on the same disk.
# LUKS is set up manually (not via disko) to preserve Windows partitions.
# See hardware-configuration.nix for LUKS/filesystem declarations.
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
    editors.enable = true;
    fhs.enable = true;
    vm = {
      enable = true;
      dosbox.enable = true;
    };
  };

  system.stateVersion = "26.05";
}
