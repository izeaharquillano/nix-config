{ config, pkgs, lib, ... }:

{
  boot.kernelParams = [ "amd_pstate=active" ];

  boot.zswap = {
    enable = true;
    compressor = "zstd";
    zpool = "zsmalloc";
    maxPoolPercent = 25;
    acceptThresholdPercent = 90;
    shrinkerEnabled = true;
  };

  boot.kernel.sysctl."vm.swappiness" = 10;
}
