{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # host-specific packages
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = false;
    args = [ "--rt" ];
  };

  programs.gamemode.enable = true;
}
