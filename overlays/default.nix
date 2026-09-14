# No `lib` in scope inside overlays; filter files manually.
final: prev:
let
  overlayFiles = builtins.filter (f: f != "default.nix" && builtins.match ".*\\.nix" f != null) (
    builtins.attrNames (builtins.readDir ./.)
  );

  importedOverlays = map (f: import (./. + "/${f}") final prev) overlayFiles;
in
builtins.foldl' (acc: overlay: acc // overlay) { } importedOverlays
