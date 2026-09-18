# Host HM: compositors/features explicit per host (importing IS enabling).
{ inputs, ... }:
let
  hm = inputs.self.modules.homeManager;
in
{
  flake.modules.homeManager.padrick =
    { pkgs, lib, ... }:
    {
      imports = [
        hm.linux-gui
        hm.niri
        hm.hyprland
        hm.vscode
        hm.p2p
        hm.podman
        hm.fhs
        hm.vm-qemu
        hm.vm-bottles
        hm.vm-dosbox
        hm.dotnet
      ];

      home.packages = [
        pkgs.btop
      ];

      xdg.configFile = inputs.self.lib.mkHostConfigFiles ./config;

      # Mic-mute LED sync (user unit, so HM — not a NixOS unit).
      systemd.user.services.mic-mute-led-sync =
        let
          syncScript = pkgs.writeShellScript "mic-mute-led-sync" ''
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
        in
        {
          Unit = {
            Description = "Mic Mute LED Sync";
            PartOf = [ "graphical-session.target" ];
            Wants = [
              "pipewire.service"
              "wireplumber.service"
            ];
            After = [
              "pipewire.service"
              "wireplumber.service"
            ];
          };
          Install.WantedBy = [ "graphical-session.target" ];
          Service = {
            Restart = "always";
            RestartSec = "2s";
            Environment = "PATH=${
              lib.makeBinPath [
                pkgs.wireplumber
                pkgs.pulseaudio
                pkgs.gnugrep
                pkgs.coreutils
              ]
            }";
            ExecStart = "${syncScript}";
          };
        };
    };
}
