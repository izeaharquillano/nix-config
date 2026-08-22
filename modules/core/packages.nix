{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    tmux
    sbctl
    xdg-user-dirs
  ];
}
