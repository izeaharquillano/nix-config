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
    dosbox
    gparted
    discord-ptb
    pavucontrol
    proton-vpn
    nemo-with-extensions
    (bottles.override { removeWarningPopup = true; })
  ];
}
