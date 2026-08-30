{ config, inputs, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-host-settings.kdl".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/hosts/padrick/config/niri-host-settings.kdl";
  xdg.configFile."hypr/hypr-host-settings.lua".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/hosts/padrick/config/hypr-host-settings.lua";
}
