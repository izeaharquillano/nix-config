# Gaming stack (Steam, Gamescope, Gamemode, MangoHud).
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:

    {
      environment.systemPackages = [
        pkgs.mangohud
        pkgs.goverlay
      ];

      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          extraCompatPackages = [
            pkgs.proton-ge-bin
          ];
        };

        gamescope = {
          enable = true;
          capSysNice = false;
        };

        gamemode.enable = true;
      };
    };
}
