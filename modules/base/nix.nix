# Multi-Context Aspect: the same nix settings shared across operating systems.
# Dendritic modules: flake.modules.nixos.base-nix, flake.modules.darwin.base-nix
# Linux-only settings gated on `isDarwin` for nix-darwin compat.
{ ... }:
let
  nix-body =
    {
      pkgs,
      lib,
      inputs ? null,
      ...
    }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    in
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
          trusted-users = [
            "root"
          ]
          ++ (if isDarwin then [ "@admin" ] else [ "@wheel" ]);
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        }
        // lib.optionalAttrs (!isDarwin) {
          sandbox = true;
        };
      };
    };
in
{
  flake.modules.nixos.base-nix = nix-body;
  flake.modules.darwin.base-nix = nix-body;
}
