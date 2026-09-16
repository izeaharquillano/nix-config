# Hosts that import this get the `/home` subvolume rolled back in initrd
# (see `impermanence-btrfs`, which derives the wipe from the declared
# `users.${username}` persistence) plus bind mounts from `/persist`.
# Everything not listed here is wiped on boot: `.cache`, `.thumbnails`,
# and `.npm` are intentionally absent.
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

        # Target of the `users.${username}` bind mounts — must be mounted early.
        fileSystems."/home".neededForBoot = true;

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
