{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    dosbox
  ];
}
