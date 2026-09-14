# Simple Aspect: tuigreet login manager
# Dendritic module: flake.modules.nixos.greetd
{
  flake.modules.nixos.greetd =
    { config, pkgs, ... }:

    {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
          };
        };
      };

      systemd.services.greetd = {
        after = [ "systemd-timesyncd.service" ];
        wants = [ "systemd-timesyncd.service" ];
      };

      systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
        # Store path required; /bin/kill is absent on NixOS.
        ExecStartPre = [
          "-${pkgs.procps}/bin/kill -s RTMIN+21 1"
        ];
        ExecStopPost = [
          "-${pkgs.procps}/bin/kill -s RTMIN+20 1"
        ];
      };
    };
}
