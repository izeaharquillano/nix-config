# Per-system custom packages. Sources live in `pkgs/` and are also exposed via
# `overlays.default` for NixOS system `pkgs`. Built here with the centralized
# `pkgs` from `modules/tools/nixpkgs.nix` (allowUnfree + overlays).
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        gruvbox-material-yazi = pkgs.callPackage ../../pkgs/gruvbox-material-yazi.nix { };
      };
    };
}
