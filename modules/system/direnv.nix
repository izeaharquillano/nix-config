# System-level direnv (NixOS + darwin).
# `nix-direnv` is required: `.envrc` uses `use flake`.
_:
let
  direnv-body = _: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
in
{
  flake.modules.nixos.direnv = direnv-body;
  flake.modules.darwin.direnv = direnv-body;
}
