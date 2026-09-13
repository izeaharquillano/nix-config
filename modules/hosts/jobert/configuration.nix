# jobert: AMD+NVIDIA gaming laptop for work/gaming.
#
# Dendritic composition root: `flake.modules.nixos.jobert` pulls together the
# desktop + features system types, the reusable `user-ize` feature, per-host
# Collector pieces (`jobert-*`), and external hardware/disk modules.
# Instantiated as `nixosConfigurations.jobert` in `flake-parts.nix`.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.jobert = {
    imports = [
      nixos.desktop
      nixos.features
      nixos.user-ize
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
      vm = {
        enable = true;
        dosbox.enable = true;
      };
      gaming.enable = true;
      containers.enable = true;
      fhs.enable = true;
      recording.enable = true;
      editors.enable = true;
    };

    system.stateVersion = "26.05";
  };
}
