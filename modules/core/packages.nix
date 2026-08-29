{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    tmux
    dnsmasq
    efibootmgr
  ];
}
