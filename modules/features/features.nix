# Collector Aspect: the full optional-feature set. Hosts import this single
# module, then toggle `features.*` options (all Conditional Aspect).
# Dendritic module: flake.modules.nixos.features
{ inputs, ... }:
{
  flake.modules.nixos.features = {
    imports = with inputs.self.modules.nixos; [
      btrfs
      impermanence
      secureboot
      zswap
      p2p
      containers
      vm
      gaming
      fhs
      editors
      recording
    ];
  };
}
