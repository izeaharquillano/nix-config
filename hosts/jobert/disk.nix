{ config, pkgs, lib, ... }:

let
  btrfsOpts = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
in
{
  fileSystems."/".options = btrfsOpts;
  fileSystems."/home".options = [ "subvol=home" ] ++ btrfsOpts;
  fileSystems."/nix".options = [ "subvol=nix" ] ++ btrfsOpts;

  swapDevices = [{
    device = "/dev/nvme1n1p4";
    options = [ "discard" ];
  }];
}
