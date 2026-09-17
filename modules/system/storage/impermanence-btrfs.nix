# Btrfs-only rollback for impermanence: always wipes `/root`, and wipes
# `/home` when home persistence is declared (`impermanence-home`
# imported — importing IS enabling, no flag). Requires the
# filesystem-agnostic `impermanence` module (`/persist` bind-mounts);
# future ext4 hosts use `impermanence` (+ `impermanence-home` for ephemeral
# home, where tmpfs `/` provides the wipe) with a tmpfs `/` instead of
# importing this. Toggle guide: `modules/system/storage/README.md`.
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
        description = "Unlocked LUKS device containing the btrfs `/root` subvolume (plus `/home` when `impermanence-home` is imported) wiped on boot.";
      };

      config =
        let
          # No flag: importing `impermanence-home` declares `users`
          # persistence, and the rollback follows that declaration.
          persistUsers = ((config.environment.persistence or { })."/persist" or { }).users or { };
          wipeHome = persistUsers != { };
        in
        {
          assertions = [
            {
              # `or {}`: clean assertion failure instead of a missing-attr error.
              assertion = (config.environment.persistence or { }) ? "/persist";
              message = "nixos.impermanence-btrfs requires nixos.impermanence (/persist persistence for the rollback host).";
            }
          ];

          boot.initrd.systemd.enable = true;

          # Target of the `impermanence-home` bind mounts when home is
          # ephemeral — must be mounted early. Moved here (not in
          # `impermanence-home`) because a separate `/home` mount only
          # exists on btrfs; ext4+tmpfs hosts have no `/home` filesystem
          # and must not gain a spurious device-less entry.
          fileSystems."/home".neededForBoot = lib.mkIf wipeHome true;

          boot.initrd.systemd.services.rollback = {
            description = "Rollback BTRFS root subvolume (plus home when ephemeral) to a pristine state";

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

              rollback_subvolume() {
                local subvol="$1"
                if [[ -e "/btrfs_tmp/$subvol" ]]; then
                  btrfs subvolume list -o "/btrfs_tmp/$subvol" |
                    cut -f9 -d' ' |
                    while IFS= read -r nested; do
                      echo "deleting /$nested subvolume..."
                      btrfs subvolume delete "/btrfs_tmp/$nested"
                    done

                  echo "deleting /$subvol subvolume..."
                  btrfs subvolume delete "/btrfs_tmp/$subvol"
                fi

                echo "creating fresh /$subvol subvolume..."
                btrfs subvolume create "/btrfs_tmp/$subvol"
              }

              rollback_subvolume root
              ${lib.optionalString wipeHome "rollback_subvolume home"}

              umount /btrfs_tmp
            '';
          };
        };
    };
}
