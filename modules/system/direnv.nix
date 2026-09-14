# System-level direnv (NixOS + darwin).
_:
let
  direnv-body = _: { programs.direnv.enable = true; };
in
{
  flake.modules.nixos.direnv = direnv-body;
  flake.modules.darwin.direnv = direnv-body;
}
