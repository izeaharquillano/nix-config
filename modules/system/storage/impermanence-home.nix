# Filesystem-agnostic ephemeral `/home` allowlist (separately toggleable:
# importing IS enabling). Safe on btrfs AND ext4+tmpfs — no rename to
# `*-btrfs`: this module only declares portable `environment.persistence`
# bind mounts from `/persist`.
# The *wipe* differs per filesystem and lives elsewhere: on btrfs,
# `impermanence-btrfs` deletes the `/home` subvolume in initrd when this
# module is imported (it derives that from the declared `users`
# persistence, and also pins `/home` early via `neededForBoot`); on
# ext4+tmpfs, `/home` is a directory on the tmpfs `/` so it is ephemeral
# with no wiper needed (do NOT import `impermanence-btrfs` there).
# Everything not listed here is wiped on boot: `.cache`, `.thumbnails`,
# and `.npm` are intentionally absent.
# Toggle guide (data-loss-safe on/off procedures): see
# `modules/system/storage/README.md` ("Ephemeral `/home`: toggling on/off safely").
{
  flake.modules.nixos.impermanence-home =
    { config, username, ... }:
    {
      config = {
        assertions = [
          {
            # `or {}`: clean assertion failure instead of a missing-attr error.
            assertion = (config.environment.persistence or { }) ? "/persist";
            message = "nixos.impermanence-home requires nixos.impermanence (/persist persistence for the home allowlist).";
          }
        ];

        # No `fileSystems."/home".neededForBoot` here: that pins a separate
        # `/home` mount early, which only exists on btrfs (disko subvolume).
        # It lives in `impermanence-btrfs` (conditional on home persistence)
        # so ext4+tmpfs hosts don't gain a spurious device-less entry.
        environment.persistence."/persist".users.${username} = {
          directories = [
            "Desktop"
            "Documents"
            "Downloads"
            "Music"
            "Pictures"
            "Public"
            "Templates"
            "Videos"
            "Projects"
            "nix-config"

            ".config"
            ".icons"
            ".vscode"
            {
              directory = ".ssh";
              mode = "0700";
            }

            ".local/share"
            ".steam"

            ".local/state/nix"
            ".local/state/home-manager"
            ".local/state/noctalia"
          ];

          files = [
            ".zsh_history"
            ".bash_history"
          ];
        };
      };
    };
}
