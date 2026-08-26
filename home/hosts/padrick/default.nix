{ config, inputs, ... }:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nixos-conf/hosts/padrick/config/niri-hardware.kdl";

  xdg.configFile."hypr/monitors.lua".source =
    mkSymlink "${config.home.homeDirectory}/nixos-conf/hosts/padrick/config/monitors.lua";
}
