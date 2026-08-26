{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    tmux
    efibootmgr
  ];
}
