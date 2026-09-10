{ pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  services.blueman.enable = true;
  services.fwupd.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}
