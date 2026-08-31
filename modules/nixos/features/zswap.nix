{ lib, config, ... }:

let
  cfg = config.myfeatures.zswap;
in
{
  options.myfeatures.zswap = {
    enable = lib.mkEnableOption "Zswap tuning with zstd compression";
  };

  config = lib.mkIf cfg.enable {
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
