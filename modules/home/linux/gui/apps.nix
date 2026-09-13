# Simple Aspect: GUI apps (mpv, discord, vpn, ...)
# Dendritic module: flake.modules.homeManager.home-gui-apps
{
  flake.modules.homeManager.home-gui-apps =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        gvfs
        mpv
        qimgv
        gparted
        localsend
        proton-vpn
        discord-ptb
        pavucontrol
        nemo-with-extensions
      ];
    };
}
