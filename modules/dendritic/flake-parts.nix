# `flake.modules` namespacing; harmless `unknown output 'modules'` warning, see NixOS/nix#15899.
{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [
    "x86_64-linux"
    # Add aarch64-linux / aarch64-darwin back when a host actually uses them;
    # extra systems triple perSystem eval (pkgs, checks, formatter, packages).
    # x86_64-darwin dropped in nixpkgs-unstable 26.11; do not re-add.
  ];
}
