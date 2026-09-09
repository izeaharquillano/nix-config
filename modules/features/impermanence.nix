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
  clean = cfg.cleanHome;
  findTargets = lib.concatStringsSep " " (map (d: "${homeDir}/${d}") clean.directories);
  findExcludes = lib.concatStringsSep " " (map (d: "! -name \"${d}\"") clean.excludes);
  touchFiles = lib.concatStringsSep " " (map (d: "${homeDir}/${d}") clean.excludeFiles);
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.features.impermanence = {
    enable = lib.mkEnableOption "Ephemeral root with persistent /persist subvolume";

    cleanHome = {
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ".cache"
          ".local/state"
          ".local/share/Trash"
          ".thumbnails"
        ];
        description = "Home directories to wipe on boot";
      };

      excludes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Directory names to skip when wiping";
      };

      excludeFiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ".local/state/noctalia/.setup-complete"
        ];
        description = "Files to preserve after wiping (re-created via touch)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
      serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c 'for d in ${findTargets}; do [ -d \"$d\" ] && echo \"$d\"; done | ${pkgs.findutils}/bin/xargs ${pkgs.findutils}/bin/find -mindepth 1 -maxdepth 1 ${findExcludes} -exec ${pkgs.coreutils}/bin/rm -rf {} +; ${pkgs.coreutils}/bin/touch ${touchFiles}'";
    };
  };
}
