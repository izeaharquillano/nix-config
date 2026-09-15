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
      cleanDirs = [
        ".cache"
        ".local/state"
        ".local/share/Trash"
        ".thumbnails"
      ];
      cleanExcludeFiles = [
        ".local/state/noctalia/.setup-complete"
      ];
    in
    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      options.features.impermanence.rollbackDevice = lib.mkOption {
        type = lib.types.str;
        # Derived from the shared `flake.lib.diskoCryptName` (`modules/nix/lib.nix`).
        default = "/dev/mapper/${inputs.self.lib.diskoCryptName}";
        description = "Unlocked LUKS device containing the btrfs `/root` subvolume wiped on boot.";
      };

      config = {
        # Auth comes from /persist, not a static password.
        users.users.${username} = {
          initialPassword = null;
          hashedPasswordFile = "${persistPath}/secrets/hashed-password";
        };

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

        fileSystems.${persistPath}.neededForBoot = true;

        # `/persist/secrets/` must exist for the install-time password file
        # and agenix-persisted keys (agenix won't create parents).
        systemd.tmpfiles.rules = [
          "d ${persistPath}/secrets 0700 root root -"
          # `z` tightens an existing file only — never creates an empty one.
          "z ${persistPath}/secrets/hashed-password 0400 root root -"
        ];

        # Ephemeral root wipes sudo's lecture flag every boot; silence it.
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
              mode = "0700";
            }
          ];

          files = [ ];
        };

        environment.etc.machine-id.source = "${persistPath}/etc/machine-id";

        # Seed via activation: a systemd service would ordering-cycle here.
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
                ${lib.getExe' pkgs.coreutils "mkdir"} -p "$(${lib.getExe' pkgs.coreutils "dirname"} "$f")"
                ${lib.getExe' pkgs.coreutils "touch"} "$f"
              done
          '';
        };
      };
    };
}
