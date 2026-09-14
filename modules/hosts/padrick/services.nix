# padrick TLP + mic LED (`resolved`/`upower` come from desktop-services).
{
  flake.modules.nixos.padrick-services =
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

      systemd.user.services.mic-mute-led-sync = {
        description = "Mic Mute LED Sync";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wants = [
          "pipewire.service"
          "wireplumber.service"
        ];
        after = [
          "pipewire.service"
          "wireplumber.service"
        ];

        serviceConfig = {
          Restart = "always";
          RestartSec = "2s";
        };

        path = [
          pkgs.wireplumber
          pkgs.pulseaudio
          pkgs.gnugrep
          pkgs.coreutils
        ];

        script = ''
          readonly LED_PATH="/sys/class/leds/platform::micmute/brightness"

          update_led() {
            vol=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null) || return 0
            if printf '%s\n' "$vol" | grep -q MUTED; then
              val=1
            else
              val=0
            fi
            (printf '%s' "$val" > "$LED_PATH") 2>/dev/null || true
          }

          # Wait for a default source (fixes 'Translate ID -1' when starting early).
          for _ in $(seq 1 60); do
            if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ >/dev/null 2>&1; then
              break
            fi
            sleep 0.5
          done
          update_led

          # Resubscribe if pactl ever exits so the service never goes dead silently.
          while true; do
            pactl subscribe 2>/dev/null | grep --line-buffered "Event 'change' on source" | while IFS= read -r _; do
              update_led
            done
            sleep 1
          done
        '';
      };
    };
}
