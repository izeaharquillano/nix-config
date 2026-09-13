# Conditional Aspect: BTRFS compression/tuning
# Dendritic module: flake.modules.nixos.btrfs
{
  flake.modules.nixos.btrfs =
    { lib, config, ... }:

    let
      cfg = config.features.btrfs;

      btrfsOpts = [
        "compress=zstd:3"
        "noatime"
        "ssd"
        "discard=async"
        "commit=120"
      ];
    in
    {
      options.features.btrfs = {
        enable = lib.mkEnableOption "BTRFS mount options with zstd compression";

        mountPaths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "/home"
            "/nix"
            "/persist"
          ];
          description = "Filesystem paths to apply BTRFS compression options to";
        };
      };

      config = lib.mkIf cfg.enable {
        fileSystems = lib.genAttrs cfg.mountPaths (path: {
          options = btrfsOpts;
        });

        services.btrfs.autoScrub = {
          enable = true;
          interval = "monthly";
          fileSystems = [ "/" ];
        };
      };
    };
}
