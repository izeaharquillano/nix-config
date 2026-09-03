{
  osConfig,
  lib,
  ...
}:

let
  p2pEnabled = lib.attrByPath [ "sysfeatures" "p2p" "enable" ] false osConfig;
in
lib.mkIf p2pEnabled {
  services.syncthing.tray.enable = true;
}
