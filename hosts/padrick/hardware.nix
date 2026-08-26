{ pkgs, lib, ... }:

{
  swapDevices = [{
    device = "/dev/nvme0n1p6";
  }];

  boot.zswap = {
    enable = true;
    compressor = "zstd";
    zpool = "zsmalloc";
    maxPoolPercent = 25;
    acceptThresholdPercent = 90;
    shrinkerEnabled = true;
  };

  boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];

  boot.kernel.sysctl."vm.swappiness" = 10;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
}
