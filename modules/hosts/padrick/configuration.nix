# padrick: ThinkPad T14 AMD Gen1 — dual-boot with Windows on the same disk.
# Disko manages disk layout; impermanence wipes root on boot.
#
# Dendritic composition root: `flake.modules.nixos.padrick` pulls together the
# desktop system type, the reusable `user-ize` feature, per-host Collector
# pieces (`padrick-*`), external hardware/disk modules, and exactly the
# feature modules this host uses — importing a module IS enabling it.
# Instantiated as `nixosConfigurations.padrick` in `flake-parts.nix`.
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
      inputs.disko.nixosModules.default
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
    ];

    networking.hostName = "padrick";

    system.stateVersion = "26.05";
  };
}
