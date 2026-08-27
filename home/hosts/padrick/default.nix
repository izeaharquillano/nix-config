{ config, inputs, ... }:

{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  # xdg.configFile."niri/niri-host-settings.kdl".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-conf/home/hosts/padrick/config/niri-host-settings.kdl";
  #
  # xdg.configFile."hypr/hypr-host-settings.lua".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-conf/home/hosts/padrick/config/hypr-host-settings.lua";

  xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;

  xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
}
