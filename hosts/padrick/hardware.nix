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

  boot.kernel.sysctl."vm.swappiness" = 10;

  hardware.cpu.amd.updateMicrocode = true;

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
