# Simple Aspect: BTRFS compression/tuning.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.btrfs
{
  flake.modules.nixos.btrfs =
    { lib, ... }:

    let
      btrfsOpts = [
        "compress=zstd:3"
        "noatime"
        "ssd"
        "discard=async"
        "commit=120"
      ];
    in
    {
      fileSystems =
        lib.genAttrs
          [
            "/home"
            "/nix"
            "/persist"
          ]
          (_path: {
            options = btrfsOpts;
          });

      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
      };
    };
}
