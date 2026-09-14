# Simple Aspect: Hyprland, PipeWire, fonts, bluetooth
# Dendritic module: flake.modules.nixos.desktop-services
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:

    {
      programs = {
        zsh.enable = true;
        dconf.enable = true;

        hyprland = {
          enable = true;
          withUWSM = true;
        };
      };

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];

      services = {
        blueman.enable = true;
        fwupd.enable = true;

        xserver.xkb = {
          layout = "us";
          variant = "";
        };

        udisks2.enable = true;
        gvfs.enable = true;

        pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };
      };

      xdg.portal = {
        enable = true;
        config = {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
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
    };
}
