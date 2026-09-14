# System-level direnv (NixOS + darwin).
_:
let
  direnv-body = _: { programs.direnv.enable = true; };
in
{
  flake.modules.nixos.base-direnv = direnv-body;
  flake.modules.darwin.base-direnv = direnv-body;
}
