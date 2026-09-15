# Shared nix settings (NixOS + darwin); Linux-only bits gated on `isDarwin`.
_:
let
  nix-body =
    {
      pkgs,
      inputs,
      username,
      ...
    }:
    let
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
      extraSubstituters = [
        "https://nix-community.cachix.org"
      ];
      extraKeys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    in
    {
      # Single global unfree opt-in (perSystem pkgs stays free-only).
      nixpkgs.config.allowUnfree = true;

      nix = {
        registry.nixpkgs = {
          flake = inputs.nixpkgs;
          exact = true;
        };

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          max-jobs = "auto";
          warn-dirty = true;
          # Primary user only (`root` already comes from the nixpkgs default).
          trusted-users = [
            username
          ]
          ++ (if isDarwin then [ "@admin" ] else [ ]);
          substituters = [
            "https://cache.nixos.org"
          ]
          ++ extraSubstituters;
          # Non-root users need the same list here.
          trusted-substituters = [
            "https://cache.nixos.org"
          ]
          ++ extraSubstituters;
          # Assignment replaces the default key, so re-include it.
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ]
          ++ extraKeys;
        };
      };
    };
in
{
  flake.modules.nixos.nix = nix-body;
  flake.modules.darwin.nix = nix-body;
}
