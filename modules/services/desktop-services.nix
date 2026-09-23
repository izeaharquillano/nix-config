# PipeWire, fonts, bluetooth (compositor-agnostic).
{
  flake.modules.nixos.desktop-services =
    { pkgs, ... }:

    {
      programs = {
        dconf.enable = true;
      };

      # Hosts add only `extraPackages` + drivers.
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      services = {
        blueman.enable = true;
        fwupd.enable = true;

        # Shared desktop defaults (were duplicated per host).
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
