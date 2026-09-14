# Enables `flake.modules` namespacing + supported systems.
{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    # x86_64-darwin dropped in nixpkgs-unstable 26.11; do not re-add.
    "aarch64-darwin"
  ];
}
