# Multi-Context Aspect: direnv enabled at system level on every OS.
# Dendritic modules: flake.modules.nixos.base-direnv, flake.modules.darwin.base-direnv
{ ... }:
let
  direnv-body =
    { ... }:

    {
      programs.direnv.enable = true;
    };
in
{
  flake.modules.nixos.base-direnv = direnv-body;
  flake.modules.darwin.base-direnv = direnv-body;
}
