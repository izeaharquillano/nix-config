{
  osConfig,
  lib,
  ...
}:

let
  p2pEnabled = lib.attrByPath [ "myfeatures" "p2p" "enable" ] false osConfig;
in
lib.mkIf p2pEnabled {
  services.syncthing.tray.enable = true;

  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };
}
