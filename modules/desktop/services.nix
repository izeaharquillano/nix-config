{ pkgs, ... }:

{
  programs.zsh.enable = true;

  programs.hyprland.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  services.blueman.enable = true;
  services.fwupd.enable = true;
  security.polkit.enable = true;

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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}
