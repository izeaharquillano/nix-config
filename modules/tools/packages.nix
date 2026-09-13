# Per-system custom packages (was `packages` in `outputs/default.nix`).
# Sources live in `pkgs/` and are also exposed via `overlays.default`.
{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      packages = {
        gruvbox-material-yazi =
          inputs.nixpkgs.legacyPackages.${system}.callPackage ../../pkgs/gruvbox-material-yazi.nix
            { };
      };
    };
}
