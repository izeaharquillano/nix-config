{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.features.impermanence;
  persistPath = "/persist";
  homeDir = "/home/${config.mySystem.username}";
  ephemeralDirs = [
    ".cache"
    ".local/state"
    ".local/share/Trash"
    ".thumbnails"
  ];
  rmCmd = lib.concatStringsSep " " (map (d: "${homeDir}/${d}") ephemeralDirs);
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.features.impermanence = {
    enable = lib.mkEnableOption "Ephemeral root with persistent /persist subvolume";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.systemd.enable = true;

    # Rollback btrfs root subvolume on every boot.
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

        mkdir -p /btrfs_tmp
        mount -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp

        if [[ -e /btrfs_tmp/root ]]; then
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

    fileSystems.${persistPath}.neededForBoot = true;

    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    users.users.${config.mySystem.username}.hashedPasswordFile =
      "${persistPath}/secrets/hashed-password";

    environment.persistence.${persistPath} = {
      enable = true;
      hideMounts = true;

      directories = [
        "/var/lib"
        "/var/lib/nixos"
        "/var/lib/systemd"
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

    # systemd creates /etc/machine-id during PID 1 init, before any service
    # runs. Impermanence's bind-mount refuses to mount over an existing file,
    # so we use environment.etc to symlink instead.
    environment.etc.machine-id.source = "${persistPath}/etc/machine-id";

    systemd.services.ensure-machine-id = {
      description = "Seed /persist/etc/machine-id if missing";
      wantedBy = [ "local-fs.target" ];
      before = [ "local-fs.target" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${persistPath}/etc";
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -f ${persistPath}/etc/machine-id ]; then ${pkgs.systemd}/bin/systemd-machine-id-setup --print > ${persistPath}/etc/machine-id; fi'";
    };

    systemd.services.clean-home = {
      description = "Wipe ephemeral home directories on boot";
      wantedBy = [ "multi-user.target" ];
      after = [ "home-manager-${config.mySystem.username}.service" ];
      wants = [ "home-manager-${config.mySystem.username}.service" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/rm -rf ${rmCmd}'";
    };
  };
}
