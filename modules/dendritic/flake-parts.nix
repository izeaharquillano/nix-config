# Dendritic infrastructure: enables the `flake.modules.<class>.<name>` namespacing
# (Simple/Multi-Context Aspects) and declares supported systems.
# Mirrors the `flake-parts.flakeModules.modules` + `systems` setup from the
# Doc-Steve/dendritic-design-with-flake-parts guide.
{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    # NOTE: nixpkgs-unstable dropped x86_64-darwin in 26.11; do not re-add
    # it until upstream restores support (use nixpkgs-26.05-darwin if needed).
    "aarch64-darwin"
  ];
}
