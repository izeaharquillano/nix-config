{ lib, config, ... }:

let
  cfg = config.features.btrfs;

  btrfsOpts = [
    "compress=zstd:3"
    "noatime"
    "ssd"
    "commit=120"
  ];
in
{
  options.features.btrfs = {
    enable = lib.mkEnableOption "BTRFS mount options with zstd compression";

    mountPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/"
        "/home"
        "/nix"
      ];
      description = "Filesystem paths to apply BTRFS compression options to";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems = lib.genAttrs cfg.mountPaths (path: {
      options = btrfsOpts;
    });
  };
}
