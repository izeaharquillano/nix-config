{ pkgs, ... }:

{
  services.resolved.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
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

  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 5;
    percentageAction = 2;
    criticalPowerAction = "PowerOff";
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="leds", KERNEL=="platform::micmute", \
    RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys/class/leds/%k/brightness"
  '';

  systemd.user.services.mic-mute-led-sync = {
    description = "Mic Mute LED Sync";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [
      "pipewire.service"
      "wireplumber.service"
    ];

    path = with pkgs; [
      wireplumber
      pulseaudio
      gnugrep
      coreutils
    ];

    script = ''
      readonly LED_PATH="/sys/class/leds/platform::micmute/brightness"

      update_led() {
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
          echo "1" > "$LED_PATH" 2>/dev/null || true
        else
          echo "0" > "$LED_PATH" 2>/dev/null || true
        fi
      }
      update_led

      pactl subscribe | grep --line-buffered "Event 'change' on source" | while read -r _; do
        update_led
      done
    '';
  };
}
