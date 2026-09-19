# jobert: AMD+NVIDIA gaming/work laptop.
# `_`-prefixed pieces are host-local (ignored by import-tree).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  hm = inputs.self.modules.homeManager;
  vars = inputs.self.lib.vars;
in
{
  flake.modules.nixos.jobert = {
    imports = [
      inputs.disko.nixosModules.default
      nixos.desktop-full
      nixos.greetd
      nixos.niri
      nixos.hyprland
      nixos.zerotier
      nixos.docker
      nixos.podman
      nixos.vm-qemu
      nixos.gaming
      nixos.dotnet
      nixos.java
      ./_disko.nix
      ./_hardware-configuration.nix
      ./_services.nix
      ./_host-settings.nix
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    home-manager.users.${vars.username} = hm.jobert;

    features.p2p.zerotier.networkId = "88c5b1f339f6593b";
  };
}
