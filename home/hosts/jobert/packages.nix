{ pkgs, ... }:

{
  home.packages = with pkgs; [
    chromium
    prismlauncher
  ];
}
