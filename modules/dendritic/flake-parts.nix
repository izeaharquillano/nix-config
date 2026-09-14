# Enables `flake.modules` namespacing + supported systems.
# NOTE: `nix flake check` (Nix 2.34.8) warns `unknown flake output 'modules'`
# because its schema allowlist predates the generic `modules.<kind>.<name>`
# output (see NixOS/nix#15899). Harmless — checks still pass. Do not work
# around it by dropping this import; `self.modules.*` composition depends on it.
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
