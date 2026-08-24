{ pkgs, ... }:

{
  services = {
    blueman.enable = true;

    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      };
    };

    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 2;
      criticalPowerAction = "PowerOff";
    };

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "ize";
      dataDir = "/home/ize/Documents";
      configDir = "/home/ize/.config/syncthing";
      settings = {
        devices = {
          "Server" = { id = "JDJRA5Z-2BXVR3Z-GTHRJND-AIJLXZW-TAMJRXF-CYYTJMM-6LKWWT7-QCD32AA"; };
        };
        folders = {
          "Obsidian" = {
            path = "/home/ize/Documents/obsidian";
            devices = [ "Server" ];
          };
        };
      };
    };

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="platform::micmute", \
      RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys/class/leds/%k/brightness"
    '';
  };

  systemd.user.services.mic-mute-led-sync = {
    description = "Mic Mute LED Sync";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "pipewire.service" "wireplumber.service" ];

    path = with pkgs; [ wireplumber pulseaudio gnugrep coreutils ];

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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
}
