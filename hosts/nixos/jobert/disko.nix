# Disko layout for jobert: ESP + LUKS2 + btrfs with impermanence and swap.
#
# WARNING: This will WIPE the entire disk. Back up any data first.
#
# Destroy, format & mount (from the nix-config root on a NixOS live ISO):
#   sudo nix --experimental-features "nix-command flakes" run \
#     github:nix-community/disko/latest -- \
#     --mode destroy,format,mount \
#     ./hosts/nixos/jobert/disko.nix
#
# Override device when installing (e.g. if disk IDs differ):
#   sudo nix --experimental-features "nix-command flakes" run \
#     github:nix-community/disko/latest -- \
#     --mode destroy,format,mount \
#     ./hosts/nixos/jobert/disko.nix \
#     --option disko.devices.disk.nixos-jobert.device /dev/nvme0n1
{
  disko.devices = {
    disk.nixos-jobert = {
      type = "disk";
      # TODO: Update this to match your disk: ls /dev/disk/by-id/ | grep nvme
      device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B728346A4FE";
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
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--iter-time 5000"
                "--key-size 256"
                "--pbkdf argon2id"
              ];
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
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "commit=120"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
