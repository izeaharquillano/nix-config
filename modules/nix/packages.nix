# Re-export overlay packages as `packages.*` (defined in `overlays/`).
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) gruvbox-material-yazi;
      };
    };
}
