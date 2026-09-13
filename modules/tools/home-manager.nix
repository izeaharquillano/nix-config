# Shared Home Manager wiring (Multi-Context Aspect): the same settings applied
# to the NixOS and nix-darwin home-manager integrations.
# Host user composition (`users.<name>`, `extraSpecialArgs`) is injected by
# the `mkNixosHost`/`mkDarwinHost` factories in `dendritic/lib.nix`.
{ inputs, ... }:
let
  home-manager-config =
    { lib, ... }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bak";
        overwriteBackup = true;
      };
    };
in
{
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  flake.modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };
}
