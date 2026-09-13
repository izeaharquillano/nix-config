# Collector Aspect: home features driven by `osConfig.features.*`.
# Dendritic module: flake.modules.homeManager.home-features
{ inputs, ... }:
{
  flake.modules.homeManager.home-features = {
    imports = with inputs.self.modules.homeManager; [
      home-features-editors
      home-features-recording
      home-features-p2p
    ];
  };
}
