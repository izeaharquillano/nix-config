# padrick TLP + mic LED udev rules (`resolved`/`upower` in desktop-services;
# the mic-mute user service itself lives in `./home.nix`).
{ pkgs, ... }:

{
  services = {
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance-performance";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";

        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersave";
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
        USB_AUTOSUSPEND = 1;

        STOP_CHARGE_THRESH_BAT0 = 80;
        START_CHARGE_THRESH_BAT0 = 75;
      };
    };

    udev.extraRules = ''
      # Group-writable LED node (0660 audio, not world-writable).
      # MODE/GROUP alone doesn't stick on thinkpad_acpi leds, so enforce via RUN.
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="platform::micmute", \
        MODE="0660", GROUP="audio", \
        RUN+="${pkgs.coreutils}/bin/chgrp audio /sys/class/leds/%k/brightness", \
        RUN+="${pkgs.coreutils}/bin/chmod 0660 /sys/class/leds/%k/brightness"
    '';
  };
}
