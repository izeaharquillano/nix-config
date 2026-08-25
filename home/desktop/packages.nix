{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utils
    waybar
    wl-clipboard
    brightnessctl
    xwayland-satellite

    # gui apps
    mpv
    qimgv
    discord-ptb
    pavucontrol
  ];
}
