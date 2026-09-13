# Multi-Context Aspect: the same nix settings shared across operating systems.
# Dendritic modules: flake.modules.nixos.base-nix, flake.modules.darwin.base-nix
{ ... }:
let
  nix-body =
    {
      pkgs,
      lib,
      inputs ? null,
      ...
    }:

    {
      nixpkgs.config.allowUnfree = true;

      nix = {
        registry = lib.optionalAttrs (inputs != null && inputs ? nixpkgs) {
          nixpkgs = {
            flake = inputs.nixpkgs;
            exact = true;
          };
        };

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "recursive-nix"
          ];
          max-jobs = "auto";
          http-connections = 50;
          warn-dirty = false;
          sandbox = true;
          trusted-users = [
            "root"
            "@wheel"
          ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };
    };
in
{
  flake.modules.nixos.base-nix = nix-body;
  flake.modules.darwin.base-nix = nix-body;
}
