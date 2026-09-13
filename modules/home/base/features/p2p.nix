# Simple Aspect: Syncthing tray applet.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.homeManager.home-features-p2p
{
  flake.modules.homeManager.home-features-p2p = {
    services.syncthing.tray.enable = true;
  };
}
