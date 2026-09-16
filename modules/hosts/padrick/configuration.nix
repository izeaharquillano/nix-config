# padrick: ThinkPad T14 AMD, Windows dual-boot, impermanence root + ephemeral home.
# `_`-prefixed pieces are host-local (ignored by import-tree).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  hm = inputs.self.modules.homeManager;
  vars = inputs.self.lib.vars;
in
{
  flake.modules.nixos.padrick = {
    imports = [
      inputs.disko.nixosModules.default
      nixos.desktop-full
      nixos.impermanence-home
      nixos.greetd
      nixos.niri
      nixos.hyprland
      nixos.docker
      nixos.podman
      nixos.vm-qemu
      ./_disko.nix
      ./_hardware-configuration.nix
      ./_services.nix
      ./_host-settings.nix
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
    ];

    home-manager.users.${vars.username} = hm.padrick;
  };
}
