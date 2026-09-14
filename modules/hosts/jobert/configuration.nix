# jobert: AMD+NVIDIA gaming/work laptop.
# Composition root (`flake.modules.nixos.jobert`); see `flake-parts.nix`.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.jobert = {
    imports = [
      nixos.desktop
      nixos.user-ize
      nixos.btrfs
      nixos.impermanence
      nixos.secureboot
      nixos.zswap
      nixos.p2p
      nixos.p2p-zerotier
      nixos.containers
      nixos.fhs
      nixos.vm-qemu
      nixos.vm-bottles
      nixos.vm-dosbox
      nixos.gaming
      nixos.jobert-disko
      nixos.jobert-hardware
      nixos.jobert-packages
      nixos.jobert-services
      nixos.jobert-host-settings
      # disko from `desktop`; hardware profiles stay per-host.
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    networking.hostName = "jobert";

    features.p2p.zerotier.networkId = "88c5b1f339f6593b";

    system.stateVersion = "26.05";
  };
}
