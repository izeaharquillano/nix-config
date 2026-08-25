{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    tmux
    sbctl
    efibootmgr
  ];
}
