# padrick: ThinkPad T14 AMD Gen1 — dual-boot with Windows on the same disk.
# Disko manages disk layout; impermanence wipes root on boot.
#
# Dendritic composition root: `flake.modules.nixos.padrick` pulls together the
# desktop + features system types, the reusable `user-ize` feature, per-host
# Collector pieces (`padrick-*`), and external hardware/disk modules.
# Instantiated as `nixosConfigurations.padrick` in `flake-parts.nix`.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
in
{
  flake.modules.nixos.padrick = {
    imports = [
      nixos.desktop
      nixos.features
      nixos.user-ize
      nixos.padrick-disko
      nixos.padrick-hardware
      nixos.padrick-packages
      nixos.padrick-services
      nixos.padrick-host-settings
      inputs.disko.nixosModules.default
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
  };
}
