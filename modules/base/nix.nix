# Shared nix settings (NixOS + darwin); Linux-only bits gated on `isDarwin`.
_:
let
  nix-body =
    {
      pkgs,
      inputs,
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
          # `warn-dirty=false` hides uncommitted changes; keep warnings on.
          warn-dirty = true;
          trusted-users = [
            "root"
          ]
          ++ (if isDarwin then [ "@admin" ] else [ "@wheel" ]);
          substituters = [
            "https://cache.nixos.org"
          ]
          ++ extraSubstituters;
          # Non-root users need matching `trusted-substituters`.
          trusted-substituters = [
            "https://cache.nixos.org"
          ]
          ++ extraSubstituters;
          # Assigning replaces the nixpkgs default (cache.nixos.org key),
          # so re-include it explicitly alongside extras.
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ]
          ++ extraKeys;
        };
      };
    };
in
{
  flake.modules.nixos.base-nix = nix-body;
  flake.modules.darwin.base-nix = nix-body;
}
