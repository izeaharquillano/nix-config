# Generic compress/noatime for `/`, `/home`, `/nix` (device-specific opts
# live in disko; the two merge).
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
