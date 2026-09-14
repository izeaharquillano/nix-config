# padrick: ThinkPad T14 AMD Gen1, Windows dual-boot, impermanence root.
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  vars = inputs.self.lib.vars;
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
      nixos.padrick-services
      nixos.padrick-host-settings
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
    ];

    # Hostname comes from the `mkNixosHost` factory (`mkDefault`);
    # override here with `mkForce` only if needed without the factory.

    features.p2p.syncthing.devices = {
      "${vars.syncthingServerName}".id = vars.syncthingServerId;
    };

    # Pinned per NixOS manual; do NOT bump on update.
    system.stateVersion = "26.05";
  };
}
