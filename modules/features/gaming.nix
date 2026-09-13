# Conditional Aspect: Steam, Gamescope, Gamemode
# Dendritic module: flake.modules.nixos.gaming
{
  flake.modules.nixos.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      cfg = config.features.gaming;
    in
    {
      options.features.gaming = {
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
      };
    };
}
