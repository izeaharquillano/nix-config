# Upstream flake-parts exposes `nixosConfigurations` and `homeConfigurations`
# but no `darwinConfigurations` option. This declares it so darwin hosts can
# be instantiated the same dendritic way as NixOS hosts.
{ lib, flake-parts-lib, ... }:
{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwinConfigurations = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
        description = "nix-darwin system configurations";
      };
    };
  };
}
