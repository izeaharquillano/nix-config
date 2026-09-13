# Simple Aspect: ephemeral root with persistent /persist subvolume.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.impermanence
{
  flake.modules.nixos.impermanence =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:

    let
      persistPath = "/persist";
      homeDir = "/home/${config.mySystem.username}";
      # Home directories to wipe on boot (+ names to skip, files to re-touch).
      cleanDirs = [
        ".cache"
        ".local/state"
        ".local/share/Trash"
        ".thumbnails"
      ];
      cleanExcludes = [ ];
      cleanExcludeFiles = [
        ".local/state/noctalia/.setup-complete"
      ];
      findTargets = lib.concatStringsSep " " (map (d: "${homeDir}/${d}") cleanDirs);
      findExcludes = lib.concatStringsSep " " (map (d: "! -name \"${d}\"") cleanExcludes);
      touchFiles = lib.concatStringsSep " " (map (d: "${homeDir}/${d}") cleanExcludeFiles);
    in
    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      # With impermanence, no static password is set (see users/ize.nix):
      # authentication comes from /persist/secrets/hashed-password.
      users.users.${config.mySystem.username} = {
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
