{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop-cuda
    chromium
    prismlauncher
  ];
}
