# Desktop core every host gets. Compositors, containers, `vm-qemu`,
# `gaming`, `zerotier` stay per-host (importing IS enabling).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  vars = inputs.self.lib.vars;
in
{
  flake.modules.nixos.desktop-full =
    { lib, ... }:
    {
      imports = [
        nixos.desktop
        nixos.user-ize
        nixos.btrfs
        nixos.impermanence
        nixos.impermanence-btrfs
        nixos.secureboot
        nixos.zswap
        nixos.p2p
        nixos.fhs
      ];

      # Shared Syncthing peer; `mkForce` to replace per host.
      features.p2p.syncthing.devices = lib.mkDefault {
        "${vars.syncthingServerName}".id = vars.syncthingServerId;
      };
    };
}
