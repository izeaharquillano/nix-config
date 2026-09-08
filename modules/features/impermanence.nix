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

    # System-level persistent state
    environment.persistence.${persistPath} = {
      enable = true;
      hideMounts = true;

      directories = [
        "/var/lib"
        "/var/tmp"
        "/var/cache"

        # NetworkManager connections
        "/etc/NetworkManager/system-connections"

        # SSH host keys
        {
          directory = "/etc/ssh";
          mode = "0755";
        }

      ];

      files = [
        # Machine ID (journald, etc.)
        "/etc/machine-id"
      ];
    };
  };
}
