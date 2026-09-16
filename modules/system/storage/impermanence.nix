# Filesystem-agnostic ephemeral root with persistent /persist.
# Btrfs hosts also import `impermanence-btrfs` (initrd rollback of the
# `/root` subvolume, plus `/home` when `impermanence-home` is imported);
# future ext4 hosts pair this module alone with a tmpfs `/` instead —
# no changes needed here.
{
  flake.modules.nixos.impermanence =
    {
      lib,
      pkgs,
      inputs,
      username,
      ...
    }:

    {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      config =
        let
          persistPath = "/persist";
        in
        {
          # Auth comes from /persist, not a static password.
          users.users.${username} = {
            initialPassword = null;
            hashedPasswordFile = "${persistPath}/secrets/hashed-password";
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
        };
    };
}
