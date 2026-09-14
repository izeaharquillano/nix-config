# Custom `pkgs/` packages (also via `overlays.default`); uses centralized `pkgs`.
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        gruvbox-material-yazi = pkgs.callPackage ../../pkgs/gruvbox-material-yazi.nix { };
      };
    };
}
