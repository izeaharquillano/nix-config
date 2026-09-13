# Simple Aspect: zswap with zstd.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.zswap
{
  flake.modules.nixos.zswap = {
    boot.zswap = {
      enable = true;
      compressor = "zstd";
      zpool = "zsmalloc";
      maxPoolPercent = 25;
      acceptThresholdPercent = 90;
      shrinkerEnabled = true;
    };
    boot.kernel.sysctl."vm.swappiness" = 10;
  };
}
