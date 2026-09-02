{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utils
    ncdu
    xdg-user-dirs
    waybar
    wl-clipboard
    brightnessctl
    xwayland-satellite

    # gui apps
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
