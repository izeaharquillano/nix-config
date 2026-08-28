{ config, lib, ... }:

{
  # xdg.configFile."niri/config.kdl".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-conf/config/niri/config.kdl";

  xdg.configFile."niri/config.kdl".source = ../../config/niri/config.kdl;
}
