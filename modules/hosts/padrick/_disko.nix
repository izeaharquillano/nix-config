# LUKS+btrfs+Windows. WIPES disk (keep ESP); `diskName` is immutable.
{ inputs, ... }:
inputs.self.lib.mkDiskoBtrfs {
  diskName = "nixos-padrick";
  device = "/dev/disk/by-id/nvme-KINGSTON_OM8PCP3512F-AA_50026B7684D7B346";
  withWindows = true;
  windowsSize = "122070M"; # ~128 GB
}
