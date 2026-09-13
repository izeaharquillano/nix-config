# jobert: AMD+NVIDIA gaming laptop for work/gaming.
#
# Dendritic composition root: `flake.modules.nixos.jobert` pulls together the
# desktop system type, the reusable `user-ize` feature, per-host Collector
# pieces (`jobert-*`), external hardware/disk modules, and exactly the
# feature modules this host uses — importing a module IS enabling it.
# Instantiated as `nixosConfigurations.jobert` in `flake-parts.nix`.
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
      inputs.disko.nixosModules.default
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    networking.hostName = "jobert";

    # Host-specific value for the imported p2p-zerotier module.
    features.p2p.zerotier.networkId = "88c5b1f339f6593b";

    system.stateVersion = "26.05";
  };
}
