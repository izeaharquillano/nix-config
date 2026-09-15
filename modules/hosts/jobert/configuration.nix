# jobert: AMD+NVIDIA gaming/work laptop.
# `_`-prefixed pieces are host-local (ignored by import-tree).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  hm = inputs.self.modules.homeManager;
  vars = inputs.self.lib.vars;
in
{
  flake.modules.nixos.jobert =
    { lib, ... }:
    {
      imports = [
        inputs.disko.nixosModules.default
        nixos.desktop-full
        nixos.niri
        nixos.hyprland
        nixos.zerotier
        nixos.docker
        nixos.podman
        nixos.vm-qemu
        nixos.gaming
        ./_disko.nix
        ./_hardware-configuration.nix
        ./_services.nix
        ./_host-settings.nix
        inputs.nixos-hardware.nixosModules.common-cpu-amd
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-ssd
      ];

      nixpkgs.overlays = inputs.self.lib.sharedOverlays;
      networking.hostName = lib.mkDefault "jobert";

      home-manager.users.${vars.username} = hm.jobert;

      features.p2p.zerotier.networkId = "88c5b1f339f6593b";

      # Pinned; do NOT bump (single source: `vars.stateVersion`).
      system = {
        inherit (vars) stateVersion;
      };
    };
}
