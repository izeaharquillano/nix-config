# Shared HM wiring for NixOS + nix-darwin; user composition via host factories.
{ inputs, ... }:
let
  home-manager-config = _: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
    };
  };

  # NixOS-only: HM waits for network (Zen mods need it).
  nixos-network-online =
    { username, ... }:
    {
      # `network-online.target` is only meaningful with wait-online enabled.
      systemd.services.NetworkManager-wait-online.enable = true;
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
