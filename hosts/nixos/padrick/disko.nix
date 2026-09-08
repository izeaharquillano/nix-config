# Disko layout for padrick: LUKS + btrfs with Windows dual boot.
#
# Partition layout (512GB NVMe):
#   1. ESP (1GB)           — shared bootloader for NixOS and Windows
#   2. NixOS root (LUKS)   — btrfs subvolumes: root, home, nix
#   3. MS reserved (16MB)  — required for Windows
#   4. Windows data (128GB) — Windows C: drive, no disko content (installed manually)
#
# Windows recovery partition is NOT declared — Windows creates its own during install.
#
# Install order: NixOS first, then Windows.
# WARNING: This will WIPE the entire disk. Back up any data first.
#
# Destroy, format & mount (from the nix-config root on a NixOS live ISO):
#   sudo nix --experimental-features "nix-command flakes" run \
#     github:nix-community/disko/latest -- \
#     --mode destroy,format,mount \
#     ./hosts/nixos/padrick/disko.nix
{
  disko.devices = {
    disk.nixos-padrick = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-KINGSTON_OM8PCP3512F-AA_50026B7684D7B346";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0177"
                "dmask=0077"
                "noexec"
                "nosuid"
                "nodev"
              ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              initrdUnlock = true;
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountpoint = "/home";
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "8G";
                  };
                };
              };
            };
          };
          "Microsoft reserved" = {
            type = "0C01";
            priority = 290;
            size = "16M";
          };
          "Windows data" = {
            type = "0700";
            priority = 300;
            size = "122070M"; # ~128 GB (128,000,000,000 bytes)
          };
        };
      };
    };
  };
}
