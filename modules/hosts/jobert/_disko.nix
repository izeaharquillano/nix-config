# LUKS+btrfs. WIPES disk; `diskName` is immutable.
{ inputs, ... }:
inputs.self.lib.mkDiskoBtrfs {
  diskName = "nixos-jobert";
  device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B728346A4FE";
}
