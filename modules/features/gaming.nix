# Simple Aspect: gaming stack (Steam, Gamescope, Gamemode, MangoHud).
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.gaming
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        mangohud
        goverlay
      ];

      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
        };

        gamescope = {
          enable = true;
          capSysNice = false;
          args = [ "--rt" ];
        };

        gamemode.enable = true;
      };
    };
}
