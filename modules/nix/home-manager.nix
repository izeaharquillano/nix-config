# Shared HM wiring (NixOS + darwin); hosts bind the user in `configuration.nix`.
{ inputs, ... }:
let
  home-manager-config = _: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      # Single source: `flake.lib.specialArgs` (`modules/nix/lib.nix`).
      extraSpecialArgs = inputs.self.lib.specialArgs;
    };
  };

  # HM activation waits for network (Zen mods fetch at activation).
  # `NetworkManager-wait-online` timeout is shortened in `nixos.system`,
  # so offline boots stall briefly instead of the 30s upstream default.
  nixos-network-online =
    { username, ... }:
    {
      systemd.services."home-manager-${username}" = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    };
in
{
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
      nixos-network-online
    ];
  };

  flake.modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };
}
