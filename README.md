# nix-config

A multi-host, cross-platform NixOS and macOS configuration using flakes and Home Manager. A gruvbox themed (mostly) configuration implemented with Noctalia, Niri, and Hyprland.

## Desktops

| | |
|---|---|
| ![desktop1](_img/desktop1.png) | ![desktop2](_img/desktop2.png) |

## Overview

This repo uses the [dendritic pattern](https://github.com/mightyiam/dendritic) with [flake-parts](https://flake.parts/) (following [Doc-Steve's dendritic-design-with-flake-parts guide](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)): `flake.nix` is a thin `mkFlake` + `import-tree ./modules` entry point, and every file under `modules/` declares `flake.modules.<class>.<name>` pieces that hosts compose explicitly.

```
nix-config/
├── flake.nix              # Dendritic entry point (mkFlake + import-tree ./modules)
├── Justfile               # Task runner (just --list to see all commands)
├── modules/               # ALL config, auto-imported by import-tree (domain groups)
│   ├── nix/               # flake-parts infra, flake.lib (vars, host factories), perSystem tools
│   ├── system/            # OS foundation + types (desktop/server, linux-core/linux-gui)
│   ├── services/          # System daemons (ssh, p2p+zerotier, docker/podman, greetd, desktop)
│   ├── programs/          # User-facing apps (shell/dev/desktop/gaming/vm/fhs, feature closures)
│   ├── users/             # Primary user as a reusable feature
│   └── hosts/             # Per-host composition roots → [modules/hosts/README.md](modules/hosts/README.md)
├── overlays/              # Nixpkgs overlays (exposed as overlays.default)
├── pkgs/                  # Custom packages (exposed as packages.*)
├── config/                # Raw dotfiles (kitty, hypr, niri, nvim, etc.) → [config/README.md](config/README.md)
├── secrets/               # Encrypted secrets (agenix)
└── .github/workflows/     # CI
```

### Dendritic Aspects in Use

| Aspect | Where |
|---|---|
| Simple | One file = one `flake.modules.<class>.<name>` (e.g. `services/ssh.nix` → `nixos.ssh`) |
| Multi-Context | One file populates several classes (`system/nix.nix` → `nixos.nix` + `darwin.nix`, `users/ize.nix`, `nix/home-manager.nix`) |
| Inheritance | Layered system types: `desktop` / `server`, `linux-core` / `linux-gui` |
| Conditional | Options only where a module needs host-specific *values* (`zerotier.networkId`); enabling is done by importing |
| Collector | Host-local `_`-prefixed modules imported relatively; shared concerns collected by system types (`desktop-full`, `linux-gui`) |
| Constants | `flake.lib.vars` (user identity), single source in `modules/nix/lib.nix` |
| DRY | Factories in `modules/nix/lib.nix` inject identical `specialArgs`/`extraSpecialArgs` everywhere |
| Factory | `mkNixosHost` / `mkDarwinHost` instantiate hosts from dendritic modules (`mkNixosServerHost` is an alias) |

## Quick Start

```bash
# Deploy for padrick (or use just)
sudo nixos-rebuild switch --flake .#padrick

# Deploy for jobert (or use just)
sudo nixos-rebuild switch --flake .#jobert

# Build without switching
nix build .#nixosConfigurations.padrick.config.system.build.toplevel

# Format all .nix files
nix fmt
```

All commands above (and more) are available via [just](https://just.systems/) — run `just --list` to see them all. For example: `just padrick`, `just switch`, `just fmt`, `just gc`.

## Updating

```bash
# Update all flake inputs (or: just update)
nix flake update

# Update a specific input (or: just update-input nixpkgs)
nix flake update nixpkgs

# Rebuild after updating (or: just switch)
sudo nixos-rebuild switch --flake .#<hostname>

# Roll back to a previous generation (list with: just list-gens)
sudo nixos-rebuild switch --rollback
# or: sudo nixos-rebuild switch --switch-generation <num> --flake .#<hostname>

# Clean up old generations (or: just gc)
sudo nix-collect-garbage -d
```

## Adding a New Host

See [modules/hosts/README.md](modules/hosts/README.md) for the full walkthrough with code templates (dendritic pieces, disko disk layout, hardware config, services, Home Manager, Secure Boot enrollment, secrets setup, and reinstallation instructions).

**TL;DR:** create `modules/hosts/<name>/` with host-local `_`-prefixed modules (copy `_disko.nix`/hardware from an existing host, update disk ID), compose them in `configuration.nix` (`desktop-full` + `greetd` + the feature deltas the host needs + `./_*.nix` pieces; disko + HM binding stay explicit per host while overlays/hostname/stateVersion come from the `mkNixosHost` factory), compose `home.nix`, instantiate in `flake-parts.nix` with `mkNixosHost "<name>" "x86_64-linux"`, format the disk from a NixOS live ISO via `disko --mode destroy,format,mount --flake .#<name>`, deploy, add the host key to `secrets/secrets.nix`, rekey, deploy again.

## Features

Optional functionality lives in `modules/services/` (daemons) and `modules/programs/` (apps) as plain composable modules — **importing one is enabling it**, no flags. Features that span NixOS + Home Manager live together in one domain dir (feature closure: `services/p2p/`, `programs/desktop/niri/`, `programs/desktop/hyprland/`). The canonical annotated list + templates live in [modules/README.md](modules/README.md#features). Each host's `configuration.nix` / `home.nix` lists exactly what it uses (excerpt from `jobert`):

```nix
# modules/hosts/jobert/configuration.nix (excerpt; see modules/README for what each does)
imports = [
  inputs.disko.nixosModules.default # explicit per host (not hidden in the factory)
  nixos.desktop-full # desktop + user-ize + btrfs + impermanence + impermanence-btrfs + secureboot + zswap + p2p + fhs
  nixos.greetd # login manager (explicit per host, needs a compositor)
  nixos.niri
  nixos.hyprland
  nixos.vm-qemu
  nixos.gaming
  nixos.zerotier
  nixos.docker
  nixos.podman
  ./_disko.nix # host-local pieces are plain relative imports (`_`-prefixed)
  # ...
];
```

```nix
# modules/hosts/jobert/home.nix (excerpt)
imports = [
  hm.linux-gui
  hm.niri
  hm.hyprland
  hm.vscode # VS Code (or zed for Zed)
  hm.recording # OBS Studio
  hm.p2p # Syncthing tray
  hm.podman # Distrobox CLI
  hm.fhs # nix-alien CLI
  hm.vm-qemu # QEMU viewer clients
  hm.vm-bottles # Wine runner
  hm.vm-dosbox # DOSBox emulator
  hm.gaming # MangoHud/GOverlay
  # ...
];
```

Truly host-specific *values* stay options, set by the importing host:

```nix
# ZeroTier network ID for the imported zerotier module
features.p2p.zerotier.networkId = "88c5b1f339f6593b";
```

## Secrets Management

This config uses [agenix](https://github.com/ryantm/agenix) for encrypted secrets, using [age](https://github.com/FiloSottile/age) with SSH host keys.

### How It Works

1. Secrets are encrypted with age using SSH public keys from each host
2. `secrets/secrets.nix` maps each `.age` file to the public keys that can decrypt it
3. Feature modules declare `age.secrets.<name>` pointing to the `.age` file
4. At boot, agenix decrypts secrets to `/run/agenix/` with the specified mode/owner
5. Services reference the decrypted path via `config.age.secrets.<name>.path`
6. **Rekeying must be done from an existing authorized host** — a new host cannot decrypt secrets until its key has been added to `secrets.nix` and the secrets re-encrypted by a host that already has access

### Quick Reference

```bash
# Edit a secret (or: just secrets-edit <secret>.age)
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e <secret>.age

# Decrypt to stdout (or: just secrets-decrypt <secret>.age)
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -d <secret>.age

# Re-encrypt after key changes (or: just secrets-rekey)
sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey
```

### Current Secrets

| Secret | Required By | Purpose |
|--------|-------------|---------|
| `nix-access-tokens.age` | Always | Nix/GitHub access tokens for private flakes |
| `netbird-setup-key.age` | Hosts importing `nixos.p2p` | NetBird VPN auto-login key |

### Impermanence + agenix

On impermanence hosts `/etc/ssh` is a bind-mount that may not exist yet when the `agenixInstall` activation script runs on boot (decrypt fails on boot, succeeds on `switch`). Two guards cover this:

1. `age.identityPaths` lists the persistent path first — `modules/system/secrets.nix` uses `["/persist/etc/ssh/ssh_host_ed25519_key" "/etc/ssh/ssh_host_ed25519_key"]` (`/persist` has `neededForBoot`, so it is always ready; the second entry covers non-impermanence hosts and fresh installs).
2. Secrets decrypt to tmpfs (`/run/agenix/`, the agenix default). The NetBird daemon has `Restart=always` and the login unit loops on `NeedsLogin`, so a transient decrypt race self-heals. A one-time cleanup in `modules/services/p2p/default.nix` removes the pre-migration plaintext copy at `/persist/secrets/netbird-setup-key`, but only when the new tmpfs secret exists.

### Adding a Secret

1. Create: `just secrets-edit <secret-name>.age`
2. Declare keys in `secrets/secrets.nix`: `"<secret-name>.age".publicKeys = systems;`
3. Rekey from an existing authorized host: `just secrets-rekey`
4. Reference in a module:
   ```nix
    age.secrets.<secret-name> = {
      file = flakeRoot + /secrets/<secret-name>.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
   ```

### Adding a New Host to Secrets

SSH host keys are generated on first boot, so two passes are needed:

1. First deploy on the new host (generates keys): `just switch` (or `sudo nixos-rebuild switch --flake .#newhost`)
2. Grab the key: `ssh-keyscan newhost 2>/dev/null | grep ssh-ed25519`
3. Add to `secrets/secrets.nix` (on an existing host with access)
4. Rekey **from an existing authorized host**: `just secrets-rekey`
5. Second deploy on the new host (now decrypts secrets): `just switch`

### Resetting a Host (Lost SSH Keys)

Update the key binding in `secrets/secrets.nix` with the new host key, then rekey **from another authorized host**: `just secrets-rekey`. Redeploy the affected host. If the lost host was the only one with access, re-create the secret from a backup.

## Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | NixOS packages (unstable) |
| `home-manager` | User environment management |
| `nix-darwin` | macOS system management (for future `darwin/` hosts) |
| `disko` | Declarative disk partitioning (LUKS + btrfs) |
| `lanzaboote` | Secure Boot (UEFI) |
| `nixos-hardware` | NixOS hardware modules |
| `impermanence` | Ephemeral root with persistent state |
| `agenix` | Encrypted secrets management |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |
| `nix-alien` | Run unpatched binaries (used by `nixos.fhs` + `sharedOverlays`) |
| `flake-parts` | Flake module system composing `modules/` |
| `import-tree` | Recursive auto-import of `modules/` (dendritic file layout) |
| `treefmt-nix` | Nix code formatting (nixfmt, shfmt) |
| `pre-commit-hooks` | Git pre-commit hooks |

## Flake Outputs

| Output | Purpose |
|---|---|
| `nixosConfigurations.<host>` | NixOS system configurations (instantiated in `modules/hosts/*/flake-parts.nix`) |
| `darwinConfigurations.<host>` | nix-darwin configurations (none yet; see `modules/hosts/README.md` macOS section) |
| `nixosModules.default` | Overlays-only module for external flakes (not the opinionated `desktop` type) |
| `overlays.default` | Nixpkgs overlay (auto-loaded via `sharedOverlays` + `nix-alien`) |
| `packages.<system>.gruvbox-material-yazi` | Custom package |
| `checks.<system>` | Formatting + pre-commit (statix, deadnix; nixfmt via treefmt) + `checks.formatting`; per-host eval is CI dry-builds |
| `formatter.<system>` | nixfmt + shfmt wrapper |
| `apps.<system>.agenix` | agenix CLI as a flake app |
| `devShells.<system>.default` | Dev shell (`just`, treefmt formatters, `deadnix`, `statix`, `agenix`) |
| `lib` | Dendritic helpers: `vars`, `sharedOverlays`, `mkDiskoBtrfs`, host factories |
| `modules` | Published dendritic modules (`nixos.*`, `darwin.*`, `homeManager.*`) |

## Formatting & CI

```bash
nix fmt                # Format all .nix files (or: just fmt)
nix fmt -- --fail-on-change  # Check without modifying (or: just fmt-check)
```

Uses `treefmt-nix` (nixfmt for Nix, shfmt for shell scripts) and `pre-commit-hooks` (statix, deadnix) for git-level enforcement. CI runs on push/PR to `main`: flake checks + lint (statix, deadnix, treefmt) + dry builds for all hosts.

## direnv

The `.envrc` contains `use flake`, loading the dev shell automatically. Requires [direnv](https://direnv.net/) and `direnv allow` once. Add `accept-flake-config = true` to `~/.config/nix/nix.conf` if prompted.

The dev shell includes `just`, `deadnix`, `statix`, and `agenix` (nixfmt/shfmt come via the treefmt devShell). Run `just --list` to see all available commands.

## Custom Library

`flake.lib` (defined in `modules/nix/lib.nix`, single source of truth) provides:

- **`vars`** — User identity (`username`, `userfullname`, `useremail`) + shared `syncthingServer*` / `obsidianVaultRel` / `stateVersion`. Injected into every module via `specialArgs`/`extraSpecialArgs` (forwarded to HM by `nixos.home-manager`).
- **`specialArgs` / `sharedOverlays`** — Minimal uniform module args (`inputs`, `username`, `vars`, `flakeRoot`; no `hostname` — use `config.networking.hostName`) and the canonical overlay list, consumed explicitly by host `configuration.nix` files.
- **`mkHostConfigFiles`** — Shared per-host Wayland config-file helper (one more compositor file = one edit, not N hosts).
- **`mkNixosHost` / `mkDarwinHost`** — Minimal factories instantiating hosts from dendritic modules with uniform `specialArgs`. (`mkNixosServerHost` is an alias; headless just means no HM user binding.) `mkNixosHost` also injects `nixpkgs.overlays`, `networking.hostName`, and `system.stateVersion`, so host `configuration.nix` files only carry disko, feature imports, `./_*.nix` pieces, and the per-host Home Manager user binding (importing IS enabling). HM settings/agenix come from the composed modules themselves.

## Security

- **Disk Encryption:** LUKS2 full-disk encryption on all NixOS hosts (declared via disko)
- **Impermanence:** Ephemeral root with persistent state (`nixos.impermanence`); btrfs hosts also wipe the `/root` subvolume on every boot (`nixos.impermanence-btrfs`), plus `/home` on hosts importing the fs-agnostic `nixos.impermanence-home` (padrick experiment; ext4+tmpfs gets the wipe from tmpfs); only explicitly persisted state survives (toggle guide: `modules/system/storage/README.md`)
- **Firewall:** Enabled system-wide; port allowlists live with their features (`services/zerotier.nix`, `services/p2p/`, `programs/gaming.nix`, `programs/virtualisation/vm-qemu.nix`, per-host `_services.nix`)
- **SSH:** Key-based auth only, root login denied, login limited to the primary user (`AllowUsers`), auth throttling (`modules/services/ssh.nix`)
- **Secrets:** agenix with age + SSH host keys (see [Secrets Management](#secrets-management))
- **RealtimeKit:** Grants real-time scheduling to PipeWire
- **Secure Boot:** Enabled by default via `desktop-full` (Lanzaboote, requires impermanence); opt out with minimal `desktop`
- **nix-ld:** Enabled for LazyVim compatibility

## Nix Settings

Configured in `modules/system/nix.nix`, `modules/system/system.nix`, and `modules/system/secrets.nix`:

- `features.system.kernelPackage`: Configurable kernel (default: `linuxPackages_latest`)
- Primary user comes from the `username` specialArg (`flake.lib.vars.username`, default `"ize"`).
- Experimental features: `nix-command`, `flakes`
- `warn-dirty = true` (surface uncommitted changes)
- Automatic weekly `nix.optimise` and garbage collection (30-day retention)
- **GitHub access token:** Optional, for private flakes / avoiding rate limits. Add via `just secrets-edit nix-access-tokens.age` with content `access-tokens = github.com=ghp_<token>`. Auto-included via `nix.extraOptions` (`!include`) in `modules/system/secrets.nix` as `0440 root:wheel` (user + daemon readable) with an empty fallback so fresh hosts without decrypted secrets don't deadlock nix.

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
- **Icons:** Papirus-Dark (GTK)
