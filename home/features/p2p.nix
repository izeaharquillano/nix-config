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
}
