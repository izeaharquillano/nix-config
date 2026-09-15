# Host HM: compositors/features explicit per host (importing IS enabling).
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.jobert =
    { pkgs, ... }:
    {
      imports = [
        hm.linux-gui
        hm.niri
        hm.hyprland
        hm.vscode
        hm.recording
        hm.p2p
        hm.podman
        hm.fhs
        hm.vm-qemu
        hm.vm-bottles
        hm.vm-dosbox
        hm.gaming
      ];

      home.packages = [
        pkgs.btop-cuda
        pkgs.chromium
        pkgs.prismlauncher
      ];

      xdg.configFile = inputs.self.lib.mkHostConfigFiles ./config;
    };
}
