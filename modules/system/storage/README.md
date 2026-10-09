# Storage

Disko layouts + impermanence (ephemeral root/home, persistent `/persist`).

All NixOS hosts: LUKS2 + btrfs + [disko](https://github.com/nix-community/disko); impermanence via [nix-community/impermanence](https://github.com/nix-community/impermanence).

## Modules

Importing IS enabling — no flags:

| Module | File | Scope |
|---|---|---|
| `nixos.impermanence` | `impermanence.nix` | Required base: `/persist` bind-mounts, `neededForBoot`, machine-id, sudo. Filesystem-agnostic. |
| `nixos.impermanence-btrfs` | `impermanence-btrfs.nix` | Btrfs-only initrd wipe: always `/root`, plus `/home` when impermanence-home is imported. In desktop-full; never on ext4. |
| `nixos.impermanence-home` | `impermanence-home.nix` | Ephemeral-`/home` allowlist, per-host opt-in. Filesystem-agnostic (on ext4, tmpfs `/` is the wipe). |
| `nixos.btrfs` | `btrfs.nix` | `compress=zstd:3,noatime` for `/`, `/home`, `/nix` + monthly scrub. In desktop-full. |

An ephemeral `/home` means only the allowlist in impermanence-home.nix survives a reboot — .cache, .thumbnails, .npm and stray dotfiles are wiped. Live data sits at `/persist/home/<user>/…`, bind-mounted to `/home/<user>/…`.

## Ephemeral `/home`: toggling on/off safely

Read the full direction once before touching anything.

1. Back up to `/persist` first — it's never wiped. (Previous generations won't save you: their initrd wipes too. Off-disk backup is optional; it guards disk failure, not the toggle.)
2. `switch`, then reboot, then verify, then delete — in that order.
3. Never `rm -rf /persist/home/<user>` while bound — it's the same files as live home. Check `findmnt | grep "/persist/home"` is empty first.
4. Verify after every step: `findmnt -R /home | grep persist`, `ls ~/Documents`.
5. `$USER` expands in your shell before `sudo` — run from your user shell, not a root shell.

### Turning ON (persistent → ephemeral)

Next reboot wipes `/home`. Anything not allowlisted and not copied to `/persist` is gone.

1. **Extend the allowlist FIRST** if more must survive.

   ```bash
   $EDITOR modules/system/storage/impermanence-home.nix
   ```

2. **Safety net:** full copy into `/persist` (btrfs: `btrfs subvolume snapshot -r /home …` instead — instant; either way it must live under /persist).

   ```bash
   sudo mkdir -p /persist/snapshots
   sudo rsync -a --exclude='.cache/' /home/$USER/ /persist/snapshots/home-before-ephemeral/
   ```

3. **Pre-seed BEFORE adding the import** — after `switch`, empty binds shadow this data. One rsync; extras outside the allowlist are harmless.

   ```bash
   sudo mkdir -p /persist/home/$USER
   sudo rsync -a --exclude='.cache/' --exclude='.thumbnails/' --exclude='.npm/' /home/$USER/ /persist/home/$USER/
   sudo chown -R $USER:users /persist/home/$USER
   ```

4. Add `nixos.impermanence-home` to configuration.nix, then switch (NO reboot).

   ```bash
   sudo nixos-rebuild switch --flake .#<host>
   ```

5. **Rescue stragglers NOW** — non-allowlisted files vanish on reboot.

   ```bash
   findmnt -R /home | grep persist
   ls ~/Documents
   ```

6. Reboot, then verify your data + the wipe.

   ```bash
   sudo reboot
   ls ~/Documents && [ -z "$(ls -A ~/.cache 2>/dev/null)" ] && echo "wipe confirmed"
   ```

### Turning OFF (ephemeral → persistent)

Data is safe in `/persist` throughout; the risk is deleting it early or skipping the backfill.

1. **Safety net inside `/persist`** — guards a premature rm of /persist/home.

   ```bash
   sudo mkdir -p /persist/snapshots
   sudo cp -a /persist/home/$USER /persist/snapshots/home-$USER-before-off
   ```

2. Rescue anything ephemeral-only worth keeping into `/persist`.

3. Remove `nixos.impermanence-home` from configuration.nix, then switch (NO reboot, NO delete — `/home` will look empty; that's expected).

   ```bash
   sudo nixos-rebuild switch --flake .#<host>
   ls /persist/home/$USER/
   findmnt | grep "/persist/home" || echo "no home binds (expected)"
   ```

4. Backfill BEFORE reboot, and fix ownership.

   ```bash
   sudo rsync -a /persist/home/$USER/ /home/$USER/
   sudo chown -R $USER:users /home/$USER
   sudo chmod 0700 /home/$USER/.ssh
   ```

5. Reboot, verify, and days later remove the stale source (re-check binds).

   ```bash
   sudo reboot
   ls ~/Documents
   findmnt | grep "/persist/home" || sudo rm -rf /persist/home/$USER
   ```

Empty home after switch? Don't write — data is in `/persist/home/$USER/` (or the snapshot). Re-run the backfill, verify, reboot. Then delete the safety net (`rm -rf /persist/snapshots/…`, or `btrfs subvolume delete …`).

## Further reading

- [nix-community/impermanence README](https://github.com/nix-community/impermanence) — module usage, tmpfs patterns.
- [NixOS Wiki: Impermanence](https://wiki.nixos.org/wiki/Impermanence) — btrfs vs tmpfs, Home Manager notes.
