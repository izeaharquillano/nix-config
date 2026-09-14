# jobert: AMD+NVIDIA gaming/work laptop.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  vars = inputs.self.lib.vars;
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
      nixos.jobert-services
      nixos.jobert-host-settings
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    # Hostname comes from the `mkNixosHost` factory (`mkDefault`).

    features.p2p.syncthing.devices = {
      "${vars.syncthingServerName}".id = vars.syncthingServerId;
    };

    features.p2p.zerotier.networkId = "88c5b1f339f6593b";

    # Pinned per NixOS manual; do NOT bump on update.
    system.stateVersion = "26.05";
  };
}
