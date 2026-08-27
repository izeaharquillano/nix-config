{ config, inputs, ... }:

{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  # xdg.configFile."niri/niri-hardware.kdl".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-conf/home/hosts/padrick/config/niri-hardware.kdl";
  #
  # xdg.configFile."hypr/monitors.lua".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-conf/home/hosts/padrick/config/monitors.lua";

  xdg.configFile."niri/niri-hardware.kdl".source = ./config/niri-hardware.kdl;

  xdg.configFile."hypr/monitors.lua".source = ./config/monitors.lua;
}
