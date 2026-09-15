# tuigreet login manager.
{
  flake.modules.nixos.greetd =
    { config, pkgs, ... }:

    {
      # Sessions come from the compositors; bare `desktop` offers none.
      assertions = [
        {
          assertion = (config.programs.niri.enable or false) || (config.programs.hyprland.enable or false);
          message = "nixos.greetd needs a Wayland compositor: import nixos.niri and/or nixos.hyprland alongside it.";
        }
      ];

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
