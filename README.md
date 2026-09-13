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
├── modules/               # ALL config, auto-imported by import-tree
│   ├── dendritic/         # flake-parts infra, flake.lib (vars, mylib, host factories)
│   ├── tools/             # perSystem (formatter, checks, devShell, apps, packages), overlays, home-manager wiring
│   ├── base/              # Cross-platform nix/direnv (Multi-Context Aspect)
│   ├── nixos/             # System types (desktop/server) + base pieces → [modules/README.md](modules/README.md)
│   ├── features/          # Optional features (Conditional + Collector Aspects)
│   ├── users/             # Primary user as a reusable feature
│   ├── home/              # Home Manager pieces + system types → [modules/home/README.md](modules/home/README.md)
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
| Simple | One file = one `flake.modules.<class>.<name>` (e.g. `nixos/base/ssh.nix` → `nixos.base-ssh`) |
| Multi-Context | One file populates several classes (`base/nix.nix` → `nixos.base-nix` + `darwin.base-nix`, `users/ize.nix`, `tools/home-manager.nix`) |
| Inheritance | Layered system types: `nixos.desktop` / `nixos.server`, `home-linux-core` / `home-linux-gui` |
| Conditional | All `features.*` gated behind `mkEnableOption` (+ `osConfig.features.*` in home modules) |
| Collector | `nixos.features`, `home-features`, and per-host `<name>-*` pieces merged into hosts |
| Constants | `flake.lib.vars` (user identity), single source in `modules/dendritic/lib.nix` |
| DRY | Factories in `modules/dendritic/lib.nix` inject identical `specialArgs`/`extraSpecialArgs` everywhere |
| Factory | `mkNixosHost` / `mkNixosServerHost` / `mkDarwinHost` instantiate hosts from dendritic modules |

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

# Roll back to a previous generation (or: just list-gens)
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Clean up old generations (or: just gc)
sudo nix-collect-garbage -d
```

## Adding a New Host

See [modules/hosts/README.md](modules/hosts/README.md) for the full walkthrough with code templates (dendritic pieces, disko disk layout, hardware config, services, Home Manager, Secure Boot enrollment, secrets setup, and reinstallation instructions).

**TL;DR:** create `modules/hosts/<name>/` with per-aspect `flake.modules.nixos.<name>-*` pieces (copy disko/hardware from an existing host, update disk ID), compose them in `configuration.nix` (`desktop` + `features` + `user-ize` + host pieces), compose `home.nix`, instantiate in `flake-parts.nix` with `mkNixosHost "<name>" "x86_64-linux"`, format the disk from a NixOS live ISO via `disko --mode destroy,format,mount --flake .#<name>`, deploy, add the host key to `secrets/secrets.nix`, rekey, deploy again.

## Feature Options

Optional features are gated behind `mkEnableOption` in `modules/features/`. See [modules/README.md](modules/README.md) for details and templates.

```nix
features = {
  btrfs.enable = true;       # BTRFS compression/tuning
  impermanence.enable = true; # Ephemeral root, persistent /persist
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM, virt-manager, SPICE, Bottles, DOSBox
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing, NetBird VPN, LocalSend
  containers.enable = true;  # Docker (rootless), Podman, Distrobox
  fhs.enable = true;         # FHS env + nix-alien for unpatched binaries
  editors.enable = true;     # Heavy code editors (VSCode, Zed)
  recording.enable = true;   # OBS Studio and recording software
};
```

P2P also supports an optional ZeroTier sub-feature, VM supports independent toggles for QEMU, Bottles, and DOSBox, and Editors supports toggling VSCode and Zed independently:

```nix
features.p2p = {
  enable = true;
  zerotier = {
    enable = true;
    networkId = "8056c2e21c123456";
  };
};

features.vm = {
  enable = true;
  qemu.enable = true;     # QEMU/KVM, virt-manager, SPICE (default: true)
  bottles.enable = true;  # Wine runner (default: true)
  dosbox.enable = true;   # DOSBox emulator (default: false)
};

features.editors = {
  enable = true;
  vscode.enable = true;   # VS Code (default: true)
  zed.enable = true;      # Zed Editor (default: false)
};
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
| `netbird-setup-key.age` | `features.p2p.enable = true` | NetBird VPN auto-login key |

### Adding a Secret

1. Create: `just secrets-edit <secret-name>.age`
2. Declare keys in `secrets/secrets.nix`: `"<secret-name>.age".publicKeys = systems;`
3. Rekey from an existing authorized host: `just secrets-rekey`
4. Reference in a module:
   ```nix
   age.secrets.<secret-name> = {
     file = "${flakeRoot}/secrets/<secret-name>.age";
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
| `disko` | Declarative disk partitioning (LUKS + btrfs) |
| `lanzaboote` | Secure Boot (UEFI) |
| `nixos-hardware` | NixOS hardware modules |
| `impermanence` | Ephemeral root with persistent state |
| `agenix` | Encrypted secrets management |
| `niri` | Niri Wayland compositor |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |
| `flake-parts` | Flake module system composing `modules/` |
| `import-tree` | Recursive auto-import of `modules/` (dendritic file layout) |
| `treefmt-nix` | Nix code formatting (nixfmt, shfmt) |
| `pre-commit-hooks` | Git pre-commit hooks |

## Flake Outputs

| Output | Purpose |
|---|---|
| `nixosConfigurations.<host>` | NixOS system configurations (instantiated in `modules/hosts/*/flake-parts.nix`) |
| `nixosModules.default` | Reusable desktop+features module for external flakes |
| `overlays.default` | Nixpkgs overlay (auto-loaded) |
| `packages.<system>.gruvbox-material-yazi` | Custom package |
| `checks.<system>` | Formatting + per-host evaluation checks |
| `formatter.<system>` | nixfmt + shfmt wrapper |
| `apps.<system>.agenix` | agenix CLI as a flake app |
| `devShells.<system>.default` | Dev shell (nixfmt, deadnix, statix, agenix) |
| `lib` | Dendritic helpers: `vars`, `mylib`, host factories |
| `modules` | Published dendritic modules (`nixos.*`, `darwin.*`, `homeManager.*`) |

## Formatting & CI

```bash
nix fmt                # Format all .nix files (or: just fmt)
nix fmt -- --check     # Check without modifying (or: just fmt-check)
```

Uses `treefmt-nix` (nixfmt for Nix, shfmt for shell scripts) and `pre-commit-hooks` for git-level enforcement. CI runs on push/PR to `main`: flake checks + dry builds for all hosts.

## direnv

The `.envrc` contains `use flake`, loading the dev shell automatically. Requires [direnv](https://direnv.net/) and `direnv allow` once. Add `accept-flake-config = true` to `~/.config/nix/nix.conf` if prompted.

The dev shell includes `just`, `nixfmt`, `deadnix`, `statix`, and `agenix`. Run `just --list` to see all available commands.

## Custom Library

`flake.lib` (defined in `modules/dendritic/lib.nix`, single source of truth) provides:

- **`vars` / `myvars`** — User identity (`username`, `userfullname`, `useremail`). Injected into every module via `specialArgs`/`extraSpecialArgs`.
- **`mylib.scanPaths`** — Kept for external compatibility. Inside this repo, `import-tree` auto-imports everything under `modules/`, so no aggregator files are needed — creating a `.nix` file is enough (plus adding it to the relevant collector, if composed).
- **`mylib.relativeToRoot`** — Converts a repo-relative path to an absolute store path.
- **`mkNixosHost` / `mkNixosServerHost` / `mkDarwinHost`** — Factories instantiating hosts from dendritic modules with uniform `specialArgs` (`inputs`, `mylib`, `myvars`, `hostname`, `username`, `flakeRoot`).

## Security

- **Disk Encryption:** LUKS2 full-disk encryption on all NixOS hosts (declared via disko)
- **Impermanence:** Root btrfs subvolume wiped on every boot; only explicitly persisted state survives
- **Firewall:** Enabled system-wide, explicit port allowlists (`modules/nixos/base/security.nix`)
- **SSH:** Key-based auth only, root login denied (`modules/nixos/base/ssh.nix`)
- **Secrets:** agenix with age + SSH host keys (see [Secrets Management](#secrets-management))
- **RealtimeKit:** Grants real-time scheduling to PipeWire
- **Secure Boot:** Optional via `features.secureboot.enable` (Lanzaboote)
- **nix-ld:** Enabled for LazyVim compatibility

## Nix Settings

Configured in `modules/base/nix.nix` and `modules/nixos/base/system.nix`:

- `mySystem.kernelPackage`: Configurable kernel (default: `linuxPackages_latest`)
- `mySystem.username`: Primary user (default: `"ize"`)
- Experimental features: `nix-command`, `flakes`, `recursive-nix`
- `sandbox = true`, `warn-dirty = false`
- Automatic weekly `nix.optimise` and garbage collection (14-day retention)
- **GitHub access token:** Optional, for private flakes / avoiding rate limits. Add via `just secrets-edit nix-access-tokens.age` with content `access-tokens = github.com=ghp_<token>`. Auto-included via `nix.extraOptions` in `modules/nixos/base/secrets.nix`.

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
- **Icons:** Papirus-Dark (GTK)
