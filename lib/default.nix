{ lib }:

{
  scanPaths =
    dir:
    builtins.map (f: (dir + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          name: _type:
          (_type == "directory")
          || (
            (name != "default.nix")
            && (lib.strings.hasSuffix ".nix" name)
          )
        ) (builtins.readDir dir)
      )
    );
}
