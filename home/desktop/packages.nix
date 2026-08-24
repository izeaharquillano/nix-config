{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv
    qimgv
    waybar
    pavucontrol
    brightnessctl
    xwayland-satellite
  ];
}
