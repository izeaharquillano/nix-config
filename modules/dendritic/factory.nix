# Factory Aspect placeholder (host builders live in `lib.nix`).
{ lib, ... }:
{
  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Parameterized factories generating dendritic modules";
  };
}
