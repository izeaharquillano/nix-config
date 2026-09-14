# Collector Aspect: jobert LUKS+btrfs disk layout
# Dendritic module: flake.modules.nixos.jobert-disko
{
  flake.modules.nixos.jobert-disko =
    # ESP+LUKS2+btrfs+swap. WIPES disk.
    # Deploy: `disko --mode destroy,format,mount --flake .#jobert`
    # Override disk: `--option disko.devices.disk.nixos-jobert.device /dev/nvme0n1`
    {
      disko.devices = {
        disk.nixos-jobert = {
          type = "disk";
          # Confirm with: ls /dev/disk/by-id/ | grep nvme
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
    };
}
