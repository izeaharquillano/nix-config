{ config, pkgs, lib, ... }:

let
  btrfsOpts = [ "compress=zstd:3" "noatime" "ssd" "commit=120" ];
in
{
  fileSystems."/".options = btrfsOpts;
  fileSystems."/home".options = [ "subvol=home" ] ++ btrfsOpts;
  fileSystems."/nix".options = [ "subvol=nix" ] ++ btrfsOpts;
}
