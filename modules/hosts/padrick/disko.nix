# Collector Aspect: padrick LUKS+btrfs+Windows disk layout
# Dendritic module: flake.modules.nixos.padrick-disko
{
  flake.modules.nixos.padrick-disko =
    # LUKS+btrfs, ESP shared with Windows (install NixOS first). WIPES disk.
    # Deploy: `disko --mode destroy,format,mount --flake .#padrick`
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
    };
}
