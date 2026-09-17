# Single overlay; add `composeManyExtensions` back only with 2+ overlays.
final: prev:
let
  # Steam dropdown fix (upstream PR #494, merged 2026-09-09, no release yet).
  xwayland-satellite-version = "0.8.2-unstable-2026-09-09";
  xwayland-satellite-src = final.fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xwayland-satellite";
    rev = "add2795134593faafce60e404a0a75df68e9ee0c";
    hash = "sha256-0TxfMgqW0/BLD4M942c5DCKYrtPvzsPJwvdcco4LQUM=";
  };
in
{
  gruvbox-material-yazi = final.callPackage ../pkgs/gruvbox-material-yazi.nix { };

  # TODO: drop when nixpkgs carries > 0.8.2 with the fix.
  # `cargoHash` can't be used here (`overrideAttrs` leaves the precomputed
  # vendor derivation untouched), so re-vendor via `cargoDeps` instead.
  xwayland-satellite = prev.xwayland-satellite.overrideAttrs (_old: {
    version = xwayland-satellite-version;
    src = xwayland-satellite-src;
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      pname = "xwayland-satellite";
      version = xwayland-satellite-version;
      src = xwayland-satellite-src;
      hash = "sha256-s1gl9eR6Mt2QLrhfcowstPFjzwE/lz4PJhJzWYHoIHg=";
    };
  });
}
