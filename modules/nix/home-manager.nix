# Shared HM wiring (NixOS + darwin); hosts bind the user in `configuration.nix`.
{ inputs, ... }:
let
  home-manager-config =
    {
      inputs,
      username,
      vars,
      flakeRoot,
      ...
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bak";
        # Forward `flake.lib.specialArgs` — keep in sync with it.
        extraSpecialArgs = {
          inherit
            inputs
            username
            vars
            flakeRoot
            ;
        };
      };
    };

  # HM waits for network (Zen mods need it).
  nixos-network-online =
    { username, ... }:
    {
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
