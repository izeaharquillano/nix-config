{ pkgs, lib, config, ... }:

let
  cfg = config.myfeatures.gaming;
in
{
  options.myfeatures.gaming = {
    enable = lib.mkEnableOption "Gaming stack (Steam, Gamescope, Gamemode, MangoHud)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mangohud
      goverlay
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

    hardware.graphics.enable32Bit = true;
  };
}
