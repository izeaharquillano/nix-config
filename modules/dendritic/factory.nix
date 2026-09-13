# Factory Aspect placeholder: parameterized module generators live here.
# (e.g. `flake.factory.mkUser = ...`). Host builders in `lib.nix` are the
# primary factories in this repo.
{ lib, ... }:
{
  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Parameterized factories generating dendritic modules";
  };
}
