{ config, pkgs, repoRoot, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];

  xdg.configFile."kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/config/kitty/kitty.conf";
}
