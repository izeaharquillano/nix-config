# jobert power/cover behavior (`resolved`/`upower` in desktop-services).
_: {
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
    # Voice/chat host port, ZeroTier-hosted only: scoped to `zt*` (nftables
    # `iifname` wildcards are valid, and `zt*` is nixpkgs' own convention)
    # instead of world-open.
    interfaces."zt*".allowedUDPPorts = [ 7654 ];
  };
}
