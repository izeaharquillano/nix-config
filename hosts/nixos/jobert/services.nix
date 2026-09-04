{
  pkgs,
  lib,
  config,
  flakeRoot,
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

  age.secrets.zerotier-network-id = {
    file = "${flakeRoot}/secrets/zerotier-network-id.age";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.zerotierone = {
    enable = true;
  };

  networking.firewall = {
    allowedUDPPorts = [ 7654 ]; # for choicer voicer
    # allowedTCPPorts = [ 7654 ]; # for choicer voicer
  };

  systemd.services.zerotier-join = {
    description = "Join ZeroTier network from secret";
    after = [ "zerotierone.service" ];
    requires = [ "zerotierone.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      NETWORK_ID=$(cat ${config.age.secrets.zerotier-network-id.path})
      ${pkgs.zerotierone}/bin/zerotier-cli join "$NETWORK_ID"
    '';
  };
}
