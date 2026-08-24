{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
    pavucontrol
    brightnessctl
    xwayland-satellite
  ];
}
