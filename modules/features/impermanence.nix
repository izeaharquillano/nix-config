# Ephemeral root with persistent /persist.
{
  flake.modules.nixos.impermanence =
    {
      config,
      lib,
      pkgs,
      inputs,
      username,
      ...
    }:

    let
      persistPath = "/persist";
      # Home directories to wipe on boot (+ files to re-touch).
      cleanDirs = [
        ".cache"
        ".local/state"
        ".local/share/Trash"
        ".thumbnails"
      ];
      cleanExcludeFiles = [
        # Noctalia sentinel; clean-home owns the wipe.
        ".local/state/noctalia/.setup-complete"
      ];
    in
    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      options.features.impermanence.rollbackDevice = lib.mkOption {
        type = lib.types.str;
        # Must match `name = "cryptroot"` in `mkDiskoBtrfs` (`modules/dendritic/lib.nix`).
        default = "/dev/mapper/cryptroot";
        description = "Unlocked LUKS device containing the btrfs `/root` subvolume wiped on boot.";
      };

      config = {
        # No static password; auth comes from /persist/secrets/hashed-password.
        users.users.${username} = {
          initialPassword = lib.mkForce null;
          hashedPasswordFile = "${persistPath}/secrets/hashed-password";
        };

        boot.initrd.systemd.enable = true;

        boot.initrd.systemd.services.rollback = {
          description = "Rollback BTRFS root subvolume to a pristine state";

          wantedBy = [ "initrd.target" ];
          requires = [ "initrd-root-device.target" ];
          after = [
            "initrd-root-device.target"
            "systemd-cryptsetup@cryptroot.service"
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

        fileSystems.${persistPath}.neededForBoot = true;

        # Ephemeral root wipes /var/db/sudo/lectured every boot, so sudo
        # would re-show its lecture after every reboot. Silence it.
        # (Alternative: persist "/var/db/sudo/lectured" to keep lecture-once.)
        security.sudo.extraConfig = ''
          Defaults lecture = never
        '';

        environment.persistence.${persistPath} = {
          enable = true;
          hideMounts = true;

          directories = [
            # `/var/lib` covers sbctl/systemd children.
            "/var/lib"
            "/var/tmp"
            "/var/cache"
            "/var/log"
            "/etc/NetworkManager/system-connections"
            "/etc/nix"
            {
              directory = "/etc/ssh";
              mode = "0755";
            }
          ];

          files = [ ];
        };

        environment.etc.machine-id.source = "${persistPath}/etc/machine-id";

        # Seed /persist/etc/machine-id via activation (not a systemd service:
        # WantedBy + Before the same target is an ordering cycle, and /etc
        # setup needs the source to exist at activation time).
        system.activationScripts.persistMachineId = lib.stringAfter [ "var" ] ''
          mkdir -p ${persistPath}/etc
          if [ ! -f ${persistPath}/etc/machine-id ]; then
            ${pkgs.systemd}/bin/systemd-machine-id-setup --print > ${persistPath}/etc/machine-id
          fi
        '';

        systemd.services.clean-home = {
          description = "Wipe ephemeral home directories on boot";
          wantedBy = [ "multi-user.target" ];
          after = [ "local-fs.target" ];
          before = [ "home-manager-${username}.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            set -euo pipefail
            for d in ${
              lib.escapeShellArgs (map (d: "${config.users.users.${username}.home}/${d}") cleanDirs)
            }; do
                if [ ! -d "$d" ]; then
                  continue
                fi
                echo "cleaning $d..."
                ${lib.getExe' pkgs.findutils "find"} "$d" -mindepth 1 -maxdepth 1 -exec ${lib.getExe' pkgs.coreutils "rm"} -rf -- {} +
              done
              for f in ${
                lib.escapeShellArgs (map (f: "${config.users.users.${username}.home}/${f}") cleanExcludeFiles)
              }; do
                ${lib.getExe' pkgs.coreutils "mkdir"} -p "$(dirname "$f")"
                ${lib.getExe' pkgs.coreutils "touch"} "$f"
              done
          '';
        };
      };
    };
}
