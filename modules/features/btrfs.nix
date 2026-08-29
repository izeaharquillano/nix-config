{ lib, config, ... }:

let
  cfg = config.myfeatures.btrfs;
  btrfsOpts = [ "compress=zstd:3" "noatime" "ssd" "commit=120" ];
in
{
  options.myfeatures.btrfs = {
    enable = lib.mkEnableOption "BTRFS mount options with zstd compression";
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/".options = btrfsOpts;
    fileSystems."/home".options = [ "subvol=home" ] ++ btrfsOpts;
    fileSystems."/nix".options = [ "subvol=nix" ] ++ btrfsOpts;
  };
}
