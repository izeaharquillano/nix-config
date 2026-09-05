{
  pkgs,
  lib,
  config,
  ...
}:

{
  services.tlp.enable = lib.mkForce false;
  services.hdapsd.enable = false;

  services.auto-cpufreq = {
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

  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 5;
    percentageAction = 2;
    criticalPowerAction = "PowerOff";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
    IdleAction = "suspend";
    IdleActionSec = "30min";
    LidSwitchIgnoreInhibited = "yes";
  };

  services.resolved.enable = true;

  networking.firewall = {
    allowedUDPPorts = [
      7654 # choicer voicer host port
    ];
  };
}
