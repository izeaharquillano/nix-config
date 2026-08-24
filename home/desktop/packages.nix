{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utils
    waybar
    brightnessctl
    xwayland-satellite

    # gui apps
    mpv
    qimgv
    discord-ptb
    pavucontrol
  ];
}
