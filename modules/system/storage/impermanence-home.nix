# Ephemeral `/home` allowlist (importing IS enabling). Filesystem-agnostic —
# portable bind mounts only; the wipe lives in `impermanence-btrfs` (btrfs)
# or tmpfs `/` (ext4). `.cache`/`.thumbnails`/`.npm` stay unwiped on purpose.
# Guide: `modules/system/storage/README.md`.
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

        # No `fileSystems."/home".neededForBoot`: separate `/home` mounts are
        # btrfs-only (see `impermanence-btrfs`); this module stays portable.
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
