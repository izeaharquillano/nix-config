{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:

let
  cfg = config.features.impermanence;
  persistPath = "/persist";
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.features.impermanence = {
    enable = lib.mkEnableOption "Ephemeral root with persistent /persist subvolume";
  };

  config = lib.mkIf cfg.enable {
    # systemd in initrd is required for the rollback service
    boot.initrd.systemd.enable = true;

    # Rollback btrfs root subvolume on every boot.
    # Uses systemd service for proper dependency ordering:
    #   after LUKS unlock → before root mount
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";

      wantedBy = [ "initrd.target" ];
      requires = [ "initrd-root-device.target" ];
      after = [
        "initrd-root-device.target"
        # Order after LUKS is unlocked — adjust if your LUKS device has a different name
        "systemd-cryptsetup@cryptroot.service"
      ];
      before = [ "sysroot.mount" ];

      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";

      script = ''
        set -euo pipefail

        mkdir -p /btrfs_tmp
        mount -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp

        if [[ -e /btrfs_tmp/root ]]; then
          # Delete nested subvolumes under root first (e.g. var/lib/portables, var/lib/machines)
          btrfs subvolume list -o /btrfs_tmp/root |
            cut -f9 -d' ' |
            while read subvolume; do
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

    # Ensure persist is mounted before activation scripts
    fileSystems.${persistPath}.neededForBoot = true;

    # Prevent sudo lecture after each reboot
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    # Use persistent password file instead of initialPassword
    users.users.${config.mySystem.username}.hashedPasswordFile =
      "${persistPath}/secrets/hashed-password";

    # System-level persistent state
    environment.persistence.${persistPath} = {
      enable = true;
      hideMounts = true;

      directories = [
        "/var/lib"
        "/var/lib/nixos" # UID/GID allocations — without this, IDs shift on reboot
        "/var/lib/systemd"
        "/var/tmp"
        "/var/cache"
        "/var/log"

        # NetworkManager connections
        "/etc/NetworkManager/system-connections"

        # Nix registry and netrc
        "/etc/nix"

        # SSH host keys
        {
          directory = "/etc/ssh";
          mode = "0755";
        }

      ];

      files = [ ];
    };

    # machine-id: systemd creates /etc/machine-id during PID 1 init, before
    # any service runs. Impermanence's persistence-mount-file refuses to bind
    # mount over an existing non-empty file. Use environment.etc instead —
    # it creates a symlink that systemd follows transparently.
    # See: https://discourse.nixos.org/t/impermanence-a-file-already-exists-at-etc-machine-id/20267
    environment.etc.machine-id.source = "${persistPath}/etc/machine-id";

    # Ensure /persist/etc/machine-id exists before the symlink is resolved.
    # On first boot, the file won't exist yet; this seeds it so systemd can
    # find a valid machine-id.
    systemd.services.ensure-machine-id = {
      description = "Seed /persist/etc/machine-id if missing";
      wantedBy = [ "local-fs.target" ];
      before = [ "local-fs.target" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${persistPath}/etc";
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -f ${persistPath}/etc/machine-id ]; then ${pkgs.systemd}/bin/systemd-machine-id-setup --print > ${persistPath}/etc/machine-id; fi'";
    };

    # BTRFS scrub to detect and correct bit-rot
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}
