# Conditional Aspect: Syncthing tray from osConfig.features.p2p
# Dendritic module: flake.modules.homeManager.home-features-p2p
{
  flake.modules.homeManager.home-features-p2p =
    {
      osConfig,
      lib,
      ...
    }:

    let
      p2pEnabled = lib.attrByPath [ "features" "p2p" "enable" ] false osConfig;
    in
    lib.mkIf p2pEnabled {
      services.syncthing.tray.enable = true;
    };
}
