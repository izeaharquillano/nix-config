# Auto-import all .nix overlay files in this directory.
# Each file should have the signature: final: prev: { ... }
final: prev:
let
  overlayFiles = builtins.filter (f: f != "default.nix" && builtins.match ".*\\.nix" f != null) (
    builtins.attrNames (builtins.readDir ./.)
  );

  importedOverlays = map (f: import (./. + "/${f}") final prev) overlayFiles;
in
builtins.foldl' (acc: overlay: acc // overlay) { } importedOverlays
