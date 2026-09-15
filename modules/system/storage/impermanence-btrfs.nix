# Btrfs-only rollback for impermanence: wipes the `/root` subvolume in
# initrd on every boot. Requires the filesystem-agnostic `impermanence`
# module (`/persist` bind-mounts); future ext4 hosts use `impermanence`
# alone with a tmpfs `/` instead of importing this.
{
  flake.modules.nixos.impermanence-btrfs =
    {
      config,
      lib,
      inputs,
      ...
    }:

    {
      options.features.impermanence.rollbackDevice = lib.mkOption {
        type = lib.types.str;
        # Derived from the shared `flake.lib.diskoCryptName` (`modules/nix/lib.nix`).
        default = "/dev/mapper/${inputs.self.lib.diskoCryptName}";
        description = "Unlocked LUKS device containing the btrfs `/root` subvolume wiped on boot.";
      };

      config = {
        assertions = [
          {
            # `or {}`: clean assertion failure instead of a missing-attr error.
            assertion = (config.environment.persistence or { }) ? "/persist";
            message = "nixos.impermanence-btrfs requires nixos.impermanence (/persist persistence for the rollback host).";
          }
        ];

        boot.initrd.systemd.enable = true;

        boot.initrd.systemd.services.rollback = {
          description = "Rollback BTRFS root subvolume to a pristine state";

          wantedBy = [ "initrd.target" ];
          requires = [ "initrd-root-device.target" ];
          after = [
            "initrd-root-device.target"
            "systemd-cryptsetup@${inputs.self.lib.diskoCryptName}.service"
          ];
          before = [ "sysroot.mount" ];

          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";

          script = ''
            set -euo pipefail

            rollbackDevice=${lib.escapeShellArg config.features.impermanence.rollbackDevice}
            mkdir -p /btrfs_tmp
            mount -o subvol=/ "$rollbackDevice" /btrfs_tmp

            if [[ -e /btrfs_tmp/root ]]; then
              btrfs subvolume list -o /btrfs_tmp/root |
                cut -f9 -d' ' |
                while IFS= read -r subvolume; do
                  echo "deleting /$subvolume subvolume..."
                  btrfs subvolume delete "/btrfs_tmp/$subvolume"
                done

              echo "deleting /root subvolume..."
              btrfs subvolume delete /btrfs_tmp/root
            fi

            echo "creating fresh /root subvolume..."
            btrfs subvolume create /btrfs_tmp/root

            umount /btrfs_tmp
          '';
        };
      };
    };
}
