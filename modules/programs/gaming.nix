# Gaming: system Steam/Gamescope/Gamemode + per-user overlay tools.
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:

    {
      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          # Roaming laptop, not a hosted server.
          dedicatedServer.openFirewall = false;
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

  flake.modules.homeManager.gaming =
    { pkgs, ... }:

    {
      home.packages = [
        pkgs.mangohud
        pkgs.goverlay
      ];
    };
}
