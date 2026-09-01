# nixos-conf

A multi-host, cross-platform NixOS and macOS configuration using flakes and Home Manager. A gruvbox themed (mostly) configuration implemented with Noctalia, Niri, and Hyprland.

## Desktops

| | |
|---|---|
| ![desktop1](_img/desktop1.png) | ![desktop2](_img/desktop2.png) |

## Overview

```
nixos-conf/
├── flake.nix              # Entry point (inputs only, outputs delegated)
├── outputs/               # Flake outputs (nixosConfigurations, checks, devShells)
├── lib/                   # Custom helpers (scanPaths, relativeToRoot)
├── overlays/              # Nixpkgs overlays (auto-loaded)
├── pkgs/                  # Custom packages
├── vars/                  # User identity (username, email)
├── hosts/                 # Per-host NixOS configs → [hosts/README.md](hosts/README.md)
├── modules/               # System modules (core, desktop, features) → [modules/README.md](modules/README.md)
├── home/                  # Home Manager modules → [home/README.md](home/README.md)
├── config/                # Raw dotfiles (kitty, hypr, niri, nvim, etc.) → [config/README.md](config/README.md)
├── secrets/               # Encrypted secrets (agenix)
└── .github/workflows/     # CI
```

## Quick Start

```bash
# Deploy for padrick
sudo nixos-rebuild switch --flake .#padrick

# Deploy for jobert
sudo nixos-rebuild switch --flake .#jobert

# Build without switching
nix build .#nixosConfigurations.padrick.config.system.build.toplevel

# Format all .nix files
nix fmt
```

## Updating

```bash
# Update all flake inputs
nix flake update

# Update a specific input
nix flake update nixpkgs

# Rebuild after updating
sudo nixos-rebuild switch --flake .#<hostname>

# Roll back to a previous generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Clean up old generations (auto-collected weekly, 14-day retention)
sudo nix-collect-garbage -d
```

## Adding a New Host

See [hosts/README.md](hosts/README.md) for the full walkthrough with code templates (hardware config, default.nix, services, Home Manager, Secure Boot enrollment, secrets setup).

**TL;DR:** create `hosts/nixos/<name>/` and `home/hosts/nixos/<name>/`, register in `outputs/default.nix` with `mkNixosHost "<name>" "x86_64-linux"`, deploy, add the host key to `secrets/nixos.nix`, rekey, deploy again.

## Feature Options

Optional features are gated behind `mkEnableOption` in `modules/nixos/features/`. See [modules/README.md](modules/README.md) for details and templates.

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS compression/tuning
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird VPN
  docker.enable = true;      # Docker (rootless, auto-prune)
};
```

## Secrets Management

This config uses [agenix](https://github.com/ryantm/agenix) for encrypted secrets, using [age](https://github.com/FiloSottile/age) with SSH host keys.

### How It Works

1. Secrets are encrypted with age using SSH public keys from each host
2. `secrets/nixos.nix` maps each `.age` file to the public keys that can decrypt it
3. Feature modules declare `age.secrets.<name>` pointing to the `.age` file
4. At boot, agenix decrypts secrets to `/run/agenix/` with the specified mode/owner
5. Services reference the decrypted path via `config.age.secrets.<name>.path`

### Quick Reference

```bash
# Edit a secret
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e <secret>.age

# Decrypt to stdout (debugging)
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -d <secret>.age

# Re-encrypt after key changes
sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey
```

### Current Secrets

| Secret | Required By | Purpose |
|--------|-------------|---------|
| `nix-access-tokens.age` | Always | Nix/GitHub access tokens for private flakes |
| `netbird-setup-key.age` | `myfeatures.p2p.enable = true` | NetBird VPN auto-login key |

### Adding a Secret

1. Create: `sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e <secret-name>.age`
2. Declare keys in `secrets/nixos.nix`: `"<secret-name>.age".publicKeys = systems;`
3. Rekey: `sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey`
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

1. First deploy (generates keys): `sudo nixos-rebuild switch --flake .#newhost`
2. Grab the key: `ssh-keyscan newhost 2>/dev/null | grep ssh-ed25519`
3. Add to `secrets/nixos.nix` and rekey
4. Second deploy (decrypts secrets): `sudo nixos-rebuild switch --flake .#newhost`

### Resetting a Host (Lost SSH Keys)

Update the key binding in `secrets/nixos.nix` with the new host key, then `sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey` and redeploy. If the lost host was the only one with access, re-create the secret from another host or backup.

## Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | NixOS packages (unstable) |
| `home-manager` | User environment management |
| `lanzaboote` | Secure Boot (UEFI) |
| `nixos-hardware` | NixOS hardware modules |
| `agenix` | Encrypted secrets management |
| `niri` | Niri Wayland compositor |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |
| `treefmt-nix` | Nix code formatting (nixfmt, shfmt) |
| `pre-commit-hooks` | Git pre-commit hooks |

## Flake Outputs

| Output | Purpose |
|---|---|
| `nixosConfigurations.<host>` | NixOS system configurations |
| `nixosModules.default` | Reusable module for external flakes |
| `overlays.default` | Nixpkgs overlay (auto-loaded) |
| `packages.<system>.gruvbox-material-yazi` | Custom package |
| `checks.<system>` | Formatting + per-host evaluation checks |
| `formatter.<system>` | nixfmt + shfmt wrapper |
| `apps.<system>.agenix` | agenix CLI as a flake app |
| `devShells.<system>.default` | Dev shell (nixfmt, deadnix, statix, agenix) |

## Formatting & CI

```bash
nix fmt                # Format all .nix files
nix fmt -- --check     # Check without modifying
```

Uses `treefmt-nix` (nixfmt for Nix, shfmt for shell scripts) and `pre-commit-hooks` for git-level enforcement. CI runs on push/PR to `main`: flake checks + dry builds for all hosts.

## direnv

The `.envrc` contains `use flake`, loading the dev shell automatically. Requires [direnv](https://direnv.net/) and `direnv allow` once. Add `accept-flake-config = true` to `~/.config/nix/nix.conf` if prompted.

## Custom Library

The `lib/` directory provides:

- **`scanPaths`** — Auto-imports all `.nix` files in a directory (excluding `default.nix`). Adding a new module only requires creating the file.
- **`relativeToRoot`** — Converts a repo-relative path to an absolute store path.

The `vars/` directory exports user identity (`username`, `userfullname`, `useremail`).

## Security

- **Firewall:** Enabled system-wide, explicit port allowlists (`modules/nixos/core/security.nix`)
- **SSH:** Key-based auth only, root login denied (`modules/nixos/core/ssh.nix`)
- **Secrets:** agenix with age + SSH host keys (see [Secrets Management](#secrets-management))
- **RealtimeKit:** Grants real-time scheduling to PipeWire
- **Secure Boot:** Optional via `myfeatures.secureboot.enable` (Lanzaboote)
- **nix-ld:** Enabled for LazyVim compatibility

## Nix Settings

Configured in `modules/base/nix.nix` and `modules/nixos/core/system.nix`:

- `mySystem.kernelPackage`: Configurable kernel (default: `linuxPackages_latest`)
- `mySystem.username`: Primary user (default: `"ize"`)
- Experimental features: `nix-command`, `flakes`, `recursive-nix`
- `sandbox = true`, `warn-dirty = false`
- Automatic weekly `nix.optimise` and garbage collection (14-day retention)
- **GitHub access token:** Optional, for private flakes / avoiding rate limits. Add via `sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e nix-access-tokens.age` with content `access-tokens = github.com=ghp_<token>`. Auto-included via `nix.extraOptions` in `modules/nixos/core/secrets.nix`.

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
- **Icons:** Papirus-Dark (GTK)
