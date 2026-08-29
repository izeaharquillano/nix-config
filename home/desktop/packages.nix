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
    (bottles.override { removeWarningPopup = true; })
    gvfs
    mpv
    qimgv
    gparted
    discord-ptb
    pavucontrol
    nemo-with-extensions
  ];
}
