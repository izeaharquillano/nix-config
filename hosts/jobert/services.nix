{ pkgs, lib, ... }:

{
  services.tlp.enable = lib.mkForce false;
  swapDevices = [{
    device = "/dev/nvme0n1p4";
    options = [ "discard" ];
  }];

  boot.zswap = {
    enable = true;
    compressor = "zstd";
    zpool = "zsmalloc";
    maxPoolPercent = 25;
    acceptThresholdPercent = 90;
    shrinkerEnabled = true;
  };

  boot.kernel.sysctl."vm.swappiness" = 10;

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

  system.activationScripts.fedoraBootEntry = {
    text = ''
      mkdir -p /boot/loader/entries
      cat <<EOF > /boot/loader/entries/fedora.conf
      title Fedora Linux (Secure Boot)
      efi /EFI/fedora/shimx64.efi
      sort-key fedora
      EOF
      '';
  };
}
