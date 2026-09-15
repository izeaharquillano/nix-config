# padrick: ThinkPad T14 AMD, Windows dual-boot, impermanence root.
# `_`-prefixed pieces are host-local (ignored by import-tree).
{ inputs, ... }:
let
  nixos = inputs.self.modules.nixos;
  hm = inputs.self.modules.homeManager;
  vars = inputs.self.lib.vars;
in
{
  flake.modules.nixos.padrick =
    { lib, ... }:
    {
      imports = [
        inputs.disko.nixosModules.default
        nixos.desktop-full
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

      nixpkgs.overlays = inputs.self.lib.sharedOverlays;
      networking.hostName = lib.mkDefault "padrick";

      home-manager.users.${vars.username} = hm.padrick;

      # Pinned; do NOT bump (single source: `vars.stateVersion`).
      system = {
        inherit (vars) stateVersion;
      };
    };
}
