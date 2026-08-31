# Overlays cannot use mylib.scanPaths because they run inside the overlay
# function (final: prev:) where lib is not in scope. Manual filtering is
# the standard pattern for auto-importing overlay files.
final: prev:
let
  overlayFiles = builtins.filter (f: f != "default.nix" && builtins.match ".*\\.nix" f != null) (
    builtins.attrNames (builtins.readDir ./.)
  );

  importedOverlays = map (f: import (./. + "/${f}") final prev) overlayFiles;
in
builtins.foldl' (acc: overlay: acc // overlay) { } importedOverlays
