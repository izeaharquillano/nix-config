{ config, pkgs, lib, ... }:

let
  btrfsOpts = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
in
{
  fileSystems."/".options = btrfsOpts;
  fileSystems."/home".options = [ "subvol=home" ] ++ btrfsOpts;
  fileSystems."/nix".options = [ "subvol=nix" ] ++ btrfsOpts;

  swapDevices = [{
    device = "/dev/disk/by-uuid/64be0cf0-e081-46aa-84c8-03d7d602d89b";
    options = [ "discard" ];
  }];
}
