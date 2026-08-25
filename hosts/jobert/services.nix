{ pkgs, lib, ... }:

{
  services.tlp.enable = lib.mkForce false;
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

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
