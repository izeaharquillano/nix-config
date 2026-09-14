# Simple Aspect: zswap with zstd; swappiness 10 (override per-host if OOMing).
# Dendritic module: flake.modules.nixos.zswap
{
  flake.modules.nixos.zswap =
    { lib, ... }:
    {
      boot.zswap = {
        enable = true;
        compressor = "zstd";
        zpool = "zsmalloc";
        maxPoolPercent = 25;
        acceptThresholdPercent = 90;
        shrinkerEnabled = true;
      };
      boot.kernel.sysctl."vm.swappiness" = lib.mkDefault 10;
    };
}
