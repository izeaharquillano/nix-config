# GUI apps (`localsend` comes from `nixos.p2p`; don't duplicate).
{
  flake.modules.homeManager.home-gui-apps =
    { pkgs, ... }:

    {
      home.packages = [
        pkgs.gvfs # user `gio` CLI; the daemon runs system-wide.
        pkgs.mpv
        pkgs.qimgv
        pkgs.gparted
        pkgs.proton-vpn
        pkgs.discord-ptb
        pkgs.pavucontrol
        pkgs.nemo-with-extensions
      ];
    };
}
