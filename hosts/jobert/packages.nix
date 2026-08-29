{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # host-specific packages
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
}
