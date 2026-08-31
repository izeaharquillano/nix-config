{ lib }:

{
  scanPaths =
    dir:
    builtins.map (f: (dir + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          name: _type:
          (_type == "directory") || ((name != "default.nix") && (lib.strings.hasSuffix ".nix" name))
        ) (builtins.readDir dir)
      )
    );

  # Convert a repo-relative path to an absolute path.
  # Usage: map mylib.relativeToRoot [ "modules/nixos" "hosts/nixos/padrick" ]
  relativeToRoot = path: (builtins.toString ./.) + "/../${path}";

  # specialArgs passed to all NixOS, Darwin, and Home Manager modules via flake.nix.
  # All modules can expect these arguments:
  #
  #   hostname  - string  - Current host name (e.g. "padrick")
  #   flakeRoot - path    - Flake root (self) for referencing repo files
  #   inputs    - attrset - Flake inputs (nixpkgs, home-manager, etc.)
  #   mylib     - attrset - Custom library functions (scanPaths, relativeToRoot)
  #   username  - string  - Primary user username (e.g. "ize")
}
