# jobert power/cover behavior (`resolved`/`upower` come from desktop-services).
{
  flake.modules.nixos.jobert-services = {
    services = {
      # auto-cpufreq instead of TLP (padrick uses TLP); don't enable both.
      tlp.enable = false;
      hdapsd.enable = false;

      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "auto";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };

      logind.settings.Login = {
        HandleLidSwitch = "lock";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "lock";
        IdleAction = "ignore";
        IdleActionSec = "30min";
        LidSwitchIgnoreInhibited = "yes";
      };
    };

    networking.firewall = {
      allowedUDPPorts = [
        # Voice/chat host port (game comms); scope narrowly if possible.
        7654
      ];
    };
  };
}
