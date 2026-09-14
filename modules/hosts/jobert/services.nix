# Collector Aspect: jobert auto-cpufreq, logind, firewall
# Dendritic module: flake.modules.nixos.jobert-services
{
  flake.modules.nixos.jobert-services =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    {
      services = {
        tlp.enable = lib.mkForce false;
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

        upower = {
          enable = true;
          percentageLow = 20;
          percentageCritical = 5;
          percentageAction = 2;
          criticalPowerAction = "PowerOff";
        };

        logind.settings.Login = {
          HandleLidSwitch = "lock";
          HandleLidSwitchExternalPower = "lock";
          HandleLidSwitchDocked = "lock";
          IdleAction = "ignore";
          IdleActionSec = "30min";
          LidSwitchIgnoreInhibited = "yes";
        };

        resolved.enable = true;
      };

      networking.firewall = {
        allowedUDPPorts = [
          7654 # choicer voicer host port
        ];
      };
    };
}
