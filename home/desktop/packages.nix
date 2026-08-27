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
    nemo-with-extensions
    gvfs
    mpv
    qimgv
    discord-ptb
    pavucontrol
  ];
}
