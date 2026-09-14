# Syncthing tray (system daemon lives in `nixos.p2p`).
{
  flake.modules.homeManager.home-features-p2p = {
    services.syncthing.tray.enable = true;
  };
}
