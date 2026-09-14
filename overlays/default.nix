# Single overlay; add `composeManyExtensions` back only with 2+ overlays.
final: _prev: {
  gruvbox-material-yazi = final.callPackage ../pkgs/gruvbox-material-yazi.nix { };
}
