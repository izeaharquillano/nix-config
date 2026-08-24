{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv
    waybar
    pavucontrol
    brightnessctl
    xwayland-satellite
  ];
}
