{ lib, config, ... }:

let
  cfg = config.myfeatures.btrfs;

  btrfsOpts = [
    "compress=zstd:3"
    "noatime"
    "ssd"
    "commit=120"
  ];
in
{
  options.myfeatures.btrfs = {
    enable = lib.mkEnableOption "BTRFS mount options with zstd compression";
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/".options = btrfsOpts;
    fileSystems."/home".options = btrfsOpts;
    fileSystems."/nix".options = btrfsOpts;
  };
}
