{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gvfs
    mpv
    qimgv
    gparted
    localsend
    proton-vpn
    discord-ptb
    pavucontrol
    nemo-with-extensions
  ];
}
