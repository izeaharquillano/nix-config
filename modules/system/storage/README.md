# Storage

Disko layouts (`btrfs.nix` mount options) + impermanence (ephemeral root /
home with persistent `/persist`). All NixOS hosts use LUKS2 + btrfs +
[disko](https://github.com/nix-community/disko); impermanence comes from
[nix-community/impermanence](https://github.com/nix-community/impermanence).

## Modules

Three separately-toggleable impermanence modules (importing IS enabling, no
flags) plus the btrfs mount options:

| Module | File | Scope | Toggle |
|---|---|---|---|
| `nixos.impermanence` | `impermanence.nix` | Filesystem-agnostic base: `/persist` bind-mounts, `neededForBoot`, machine-id, sudo | Always imported (required) |
| `nixos.impermanence-btrfs` | `impermanence-btrfs.nix` | Btrfs-only initrd wipe: always `/root`, plus `/home` when home persistence is declared | In `desktop-full`; ext4+tmpfs hosts never import it |
| `nixos.impermanence-home` | `impermanence-home.nix` | Filesystem-agnostic ephemeral-`/home` allowlist (`environment.persistence."/persist".users.<user>`); works on btrfs AND ext4+tmpfs | Per-host opt-in: add/remove `nixos.impermanence-home` in `configuration.nix` |
| `nixos.btrfs` | `btrfs.nix` | `compress=zstd:3,noatime` for `/`, `/home`, `/nix` + monthly scrub | In `desktop-full` |

Filesystem combos:

- **btrfs (current hosts):** `impermanence` + `impermanence-btrfs` (+
  `impermanence-home` for ephemeral home). The wipe is the initrd rollback
  (delete/recreate the `/root` subvolume, plus `/home` when home persistence
  is declared).
- **ext4+tmpfs (future hosts):** `impermanence` (+ `impermanence-home` for
  ephemeral home, where tmpfs `/` provides the wipe) with a tmpfs `/` and a
  persistent `/persist` — never import `impermanence-btrfs`.

Ephemeral `/home` means: only the allowlist in `impermanence-home.nix`
survives reboot (currently `Desktop`/`Documents`/`Downloads`/`Music`/
`Pictures`/`Public`/`Templates`/`Videos`/`Projects`/`nix-config`,
`.config`/`.icons`/`.vscode`/`.ssh`, `.local/share`/`.steam`,
`.local/state/nix|home-manager|noctalia`, `.zsh_history`/`.bash_history`).
Everything else (`.cache`, `.thumbnails`, `.npm`, stray dotfiles) is wiped
every boot. While ephemeral, the canonical copy of allowlisted data is
`/persist/home/<user>/…`, bind-mounted to `/home/<user>/…`.

## Ephemeral `/home`: toggling on/off safely

Read the whole direction once before touching anything.

Golden rules (both directions, toggle-only scope — no external media required):

1. Snapshot to `/persist` first — `/persist` is never wiped, so a snapshot there survives the toggle. Booting the previous generation does NOT save you (its initrd wipes too on the ON path), but the snapshot does. External/off-disk backups are optional here (they guard disk failure, not the toggle).
2. `switch` first, reboot second, verify third, delete last.
3. Never `rm -rf /persist/home/<user>` while its binds are active — source and target are the same files via the bind, so you delete live home. Confirm `findmnt | grep "/persist/home"` is empty first.
4. After every `switch`/`reboot`, verify with `findmnt -R /home | grep persist` and `ls ~/Documents` before proceeding.
5. `$USER` below is your login name, expanded by your shell before `sudo` runs — run these from your user shell, not a root shell (where `$USER` is `root`).

### Turning ON (persistent `/home` → ephemeral)

Next reboot wipes the `/home` subvolume (btrfs) — anything not in the allowlist and not snapshotted is gone.

```bash
# 1. Read the allowlist and extend it FIRST if you need more to survive.
$EDITOR modules/system/storage/impermanence-home.nix
# 2. Toggle safety net: read-only snapshot of /home into /persist (never wiped).
#    Must live under /persist — a snapshot at / would sit on the wiped /root.
sudo mkdir -p /persist/snapshots
sudo btrfs subvolume snapshot -r /home /persist/snapshots/home-before-ephemeral
# 3. Pre-seed /persist BEFORE adding the import (no shadowing yet).
sudo mkdir -p /persist/home/$USER
for d in Desktop Documents Downloads Music Pictures Public Templates Videos Projects nix-config .config .icons .vscode .local/share .steam .local/state/nix .local/state/home-manager .local/state/noctalia; do
  [ -e "/home/$USER/$d" ] && sudo rsync -a "/home/$USER/$d/" "/persist/home/$USER/$d/"
done
[ -e /home/$USER/.ssh ] && sudo rsync -a /home/$USER/.ssh/ /persist/home/$USER/.ssh/ && sudo chmod 0700 /persist/home/$USER/.ssh
for f in .zsh_history .bash_history; do [ -e "/home/$USER/$f" ] && sudo rsync -a "/home/$USER/$f" "/persist/home/$USER/$f"; done
sudo chown -R $USER:users /persist/home/$USER
# 4. Enable: add nixos.impermanence-home to the host's configuration.nix imports.
# 5. Switch — DO NOT REBOOT YET.
sudo nixos-rebuild switch --flake .#<host>
# 6. Verify binds show your data; rescue stragglers NOW (non-allowlisted files
#    are still visible until reboot, then gone).
findmnt -R /home | grep persist
ls ~/Documents
# 7. Reboot (initrd wipes /home, binds re-populate from /persist), then verify.
sudo reboot
findmnt | grep persist
ls ~/Documents && [ -z "$(ls -A ~/.cache 2>/dev/null)" ] && echo "wipe confirmed"
```

### Turning OFF (ephemeral → persistent `/home`)

Data is safe in `/persist` throughout — the risk is deleting it too early or forgetting the backfill (you'd boot into an empty home and panic).

```bash
# 1. Toggle safety net: plain copy of the canonical copy inside /persist
#    (survives the toggle; guards a premature rm of /persist/home).
sudo mkdir -p /persist/snapshots
sudo cp -a /persist/home/$USER /persist/snapshots/home-$USER-before-off
# 2. While binds are still active, rescue anything ephemeral-only you now want
#    to keep (e.g. current ~/.cache/session files) into /persist or the snapshot.
# 3. Disable: remove nixos.impermanence-home from configuration.nix.
# 4. Switch — DO NOT REBOOT, DO NOT DELETE /persist/home yet.
sudo nixos-rebuild switch --flake .#<host>
# 5. Expect /home to look empty now (binds gone, underlying subvolume exposed).
#    Confirm data is still in /persist and no home binds remain.
ls /persist/home/$USER/
findmnt | grep "/persist/home" || echo "no home binds (expected)"
# 6. Backfill BEFORE reboot, fix ownership.
sudo rsync -a /persist/home/$USER/ /home/$USER/
sudo chown -R $USER:users /home/$USER
sudo chmod 0700 /home/$USER/.ssh
ls ~/Documents
# 7. Reboot (wiper now leaves /home alone), verify data survived.
sudo reboot
ls ~/Documents
# 8. Days later, once sure: confirm STILL no binds, then remove the stale source.
findmnt | grep "/persist/home" || sudo rm -rf /persist/home/$USER
```

If you boot into an empty home after step 4/6: don't panic, don't write much — your data is in `/persist/home/$USER/` (or `/persist/snapshots/home-$USER-before-off`). Re-run the backfill `rsync` + `chown`, verify, then reboot. Clean up the snapshot once sure: `sudo btrfs subvolume delete /persist/snapshots/home-before-ephemeral` (ON path) or `sudo rm -rf /persist/snapshots/home-$USER-before-off` (OFF path).
