{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utils
    ncdu
    waybar
    wl-clipboard
    brightnessctl
    xwayland-satellite

    # gui apps
    gvfs
    mpv
    qimgv
    gparted
    discord-ptb
    pavucontrol
    proton-vpn
    nemo-with-extensions
    (bottles.override { removeWarningPopup = true; })
  ];
}
