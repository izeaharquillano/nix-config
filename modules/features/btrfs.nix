# BTRFS compression/tuning. Disko sets device-specific opts in `mkDiskoBtrfs`
# (ESP, LUKS, /persist ssd/discard/commit); this module adds generic
# compress/noatime to the remaining btrfs mounts (merged with disko opts).
{
  flake.modules.nixos.btrfs =
    { lib, ... }:

    let
      btrfsOpts = [
        "compress=zstd:3"
        "noatime"
      ];
    in
    {
      fileSystems =
        lib.genAttrs
          [
            "/"
            "/home"
            "/nix"
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
