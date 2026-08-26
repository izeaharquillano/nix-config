{ config, pkgs, lib, ... }:

{
  boot.kernelParams = [
    "amd_pstate=active"
    "amd_pmc.suspend_delay=1"
    "pcie_aspm=off"
    "usbcore.autosuspend=-1"
  ];

  boot.zswap = {
    enable = true;
    compressor = "zstd";
    zpool = "zsmalloc";
    maxPoolPercent = 25;
    acceptThresholdPercent = 90;
    shrinkerEnabled = true;
  };

  boot.kernel.sysctl."vm.swappiness" = 10;

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
