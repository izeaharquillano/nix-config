# Simple Aspect: ephemeral root with persistent /persist subvolume.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.impermanence
{
  flake.modules.nixos.impermanence =
    {
      lib,
      pkgs,
      inputs,
      username,
      ...
    }:

    let
      persistPath = "/persist";
      homeDir = "/home/${username}";
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
      # `find <dir> -mindepth 1 -maxdepth 1 <excludes>`: paths MUST precede
      # the expression (previous xargs appended paths at the end, so find
      # always failed with "paths must precede expression" and wiped nothing).
      findExcludeArgs = lib.concatMapStringsSep " " (e: "! -name ${lib.escapeShellArg e}") cleanExcludes;
    in
    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      # With impermanence, no static password is set (see users/ize.nix):
      # authentication comes from /persist/secrets/hashed-password.
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
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${persistPath}/etc";
          ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -f ${persistPath}/etc/machine-id ]; then ${pkgs.systemd}/bin/systemd-machine-id-setup --print > ${persistPath}/etc/machine-id; fi'";
        };
      };

      systemd.services.clean-home = {
        description = "Wipe ephemeral home directories on boot";
        wantedBy = [ "multi-user.target" ];
        # Run BEFORE Home Manager activation (not after): wiping after HM
        # deletes files HM just created, and re-runs on every
        # `nixos-rebuild switch` while logged in, nuking the live session's
        # cache. Before HM it only affects stale state from previous boots.
        after = [ "local-fs.target" ];
        before = [ "home-manager-${username}.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          set -euo pipefail
          for d in ${lib.escapeShellArgs (map (d: "${homeDir}/${d}") cleanDirs)}; do
            if [ ! -d "$d" ]; then
              continue
            fi
            echo "cleaning $d..."
            ${lib.getExe' pkgs.findutils "find"} "$d" -mindepth 1 -maxdepth 1 ${findExcludeArgs} -exec ${lib.getExe' pkgs.coreutils "rm"} -rf -- {} +
          done
          for f in ${lib.escapeShellArgs (map (f: "${homeDir}/${f}") cleanExcludeFiles)}; do
            ${lib.getExe' pkgs.coreutils "mkdir"} -p "$(dirname "$f")"
            ${lib.getExe' pkgs.coreutils "touch"} "$f"
          done
        '';
      };
    };
}
