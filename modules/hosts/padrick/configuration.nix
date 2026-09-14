# padrick: ThinkPad T14 AMD Gen1, Windows dual-boot, impermanence root.
# Composition root (`flake.modules.nixos.padrick`); see `flake-parts.nix`.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.padrick = {
    imports = [
      nixos.desktop
      nixos.user-ize
      nixos.btrfs
      nixos.impermanence
      nixos.secureboot
      nixos.zswap
      nixos.p2p
      nixos.containers
      nixos.fhs
      nixos.vm-qemu
      nixos.vm-bottles
      nixos.vm-dosbox
      nixos.padrick-disko
      nixos.padrick-hardware
      nixos.padrick-packages
      nixos.padrick-services
      nixos.padrick-host-settings
      # disko from `desktop`; hardware profile stays per-host.
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
    ];

    networking.hostName = "padrick";

    system.stateVersion = "26.05";
  };
}
