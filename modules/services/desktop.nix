# Simple Aspect: PipeWire, fonts, bluetooth (compositor-agnostic).
# Hyprland lives in `programs/desktop/hyprland/`; Niri in `programs/desktop/niri/`.
# Dendritic module: flake.modules.nixos.desktop-services
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:

    {
      programs = {
        zsh.enable = true;
        dconf.enable = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      services = {
        blueman.enable = true;
        fwupd.enable = true;

        # Shared desktop defaults (was duplicated per host).
        resolved.enable = true;

        upower = {
          enable = true;
          percentageLow = 20;
          percentageCritical = 5;
          percentageAction = 2;
          criticalPowerAction = "PowerOff";
        };

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
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
      };

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;
      };
    };
}
