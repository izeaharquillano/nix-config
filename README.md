# nixos-conf

A multi-host NixOS configuration using flakes and Home Manager. A gruvbox themed (mostly) configuration implemented with Noctalia, Niri, and Hyprland. 

## Desktops

| | |
|---|---|
| ![desktop1](_img/desktop1.png) | ![desktop2](_img/desktop2.png) |

## Structure

```
.
├── flake.nix                  # Flake entry point (mkHost helper, passes hostname via specialArgs)
├── lib/                       # Custom Nix library helpers (scanPaths)
├── scripts/                   # Utility scripts (output-scale)
├── hosts/                     # Per-host NixOS system configurations
│   ├── padrick/               # ThinkPad T14 AMD Gen1 (daily use)
│   │   ├── default.nix        # Host config (imports modules, enables features)
│   │   ├── hardware-configuration.nix
│   │   ├── hardware.nix       # Kernel params, swap, VA-API
│   │   ├── packages.nix       # Host-specific system packages
│   │   └── services.nix       # TLP, UPower, mic-mute LED sync
│   └── jobert/                # AMD + NVIDIA gaming laptop
│       ├── default.nix
│       ├── hardware-configuration.nix
│       ├── hardware.nix       # NVIDIA driver, boot params, session vars
│       ├── packages.nix
│       └── services.nix       # auto-cpufreq, UPower, systemd-resolved
├── modules/                   # NixOS system modules
│   ├── core/                  # Shared by all hosts (auto-imported via scanPaths)
│   │   ├── system.nix         # Boot, networking, nix settings (recursive-nix, warn-dirty)
│   │   ├── locale.nix         # Timezone, locale
│   │   ├── ssh.nix            # OpenSSH (key-based auth only)
│   │   ├── secrets.nix        # agenix secret declarations (age key config, secrets)
│   │   └── packages.nix       # Base system packages
│   ├── desktop/               # Desktop environment (auto-imported via scanPaths)
│   │   ├── greetd.nix         # Login manager (tuigreet)
│   │   ├── niri.nix           # Niri Wayland compositor
│   │   └── services.nix       # Pipewire, fonts, rtkit, bluetooth
│   ├── features/              # Optional feature modules (mkEnableOption, auto-imported)
│   │   ├── btrfs.nix          # BTRFS mount options (myfeatures.btrfs.enable)
│   │   ├── secureboot.nix     # UEFI Secure Boot via Lanzaboote
│   │   ├── gaming.nix         # Steam, Gamescope, Gamemode, MangoHud
│   │   ├── vm.nix             # QEMU/KVM + virt-manager
│   │   ├── zswap.nix          # Zswap with zstd compression
│   │   ├── p2p.nix            # Syncthing + NetBird
│   │   └── backup.nix         # Restic backups (configurable paths, repository, exclude)
│   └── security.nix           # Neovim, nix-ld, firewall, polkit
├── secrets/                    # Encrypted secrets (agenix)
│   ├── secrets.nix            # Public key declarations for each secret
│   ├── nix-access-tokens.age  # Nix/GitHub access tokens (encrypted)
│   └── netbird-setup-key.age  # NetBird VPN setup key (encrypted)
├── home/                      # Home Manager modules
│   ├── core/                  # Shell, packages, XDG (auto-imported via scanPaths)
│   │   ├── shell.nix          # Git, bash, zsh (shared aliases via let binding), starship, zoxide
│   ├── desktop/               # GUI app configs (auto-imported via scanPaths)
│   └── hosts/                 # Host-specific HM overrides
│       ├── padrick/
│       │   ├── default.nix    # Imports core + desktop, symlinks host configs
│       │   ├── packages.nix   # btop
│       │   └── config/        # Host-specific dotfiles
│       │       ├── niri-host-settings.kdl
│       │       ├── hypr-host-settings.lua
│       │       └── noctalia-host-settings.toml
│       └── jobert/
│           ├── default.nix
│           ├── packages.nix   # btop-cuda, chromium, prismlauncher
│           └── config/
│               ├── niri-host-settings.kdl
│               ├── hypr-host-settings.lua
│               └── noctalia-host-settings.toml
└── config/                    # Shared raw dotfiles (nvim, hypr, niri, kitty, tmux, noctalia)
```

## Quick Start

```bash
# Symlink this repo to /etc/nixos (required for shell aliases like bldflk)
sudo ln -s /path/to/nixos-conf /etc/nixos

# Set up secrets (first time only)
# 1. Get your host's SSH public key: ssh-keyscan <hostname> 2>/dev/null | grep ssh-ed25519
# 2. Add keys to secrets/secrets.nix
# 3. Create encrypted secrets: agenix -e <secret-name>.age

# Deploy for padrick
sudo nixos-rebuild switch --flake .#padrick

# Deploy for jobert
sudo nixos-rebuild switch --flake .#jobert

# Build without switching
nix build .#nixosConfigurations.padrick.config.system.build.toplevel

# Format all .nix files
nix fmt
```

## Adding a New Host

1. Create the host directory and generate hardware config:

   ```bash
   mkdir -p hosts/<name>
   mkdir -p home/hosts/<name>/config
   ```

2. On the target machine, generate the hardware config:

   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix
   ```

3. Create `hosts/<name>/default.nix` (see [hosts/README.md](hosts/README.md) for a template)
4. Create `hosts/<name>/hardware.nix`, `packages.nix`, `services.nix`
5. Create `home/hosts/<name>/default.nix` and `packages.nix`
6. Create `home/hosts/<name>/config/` with monitor configs:
   - `niri-host-settings.kdl` for host-specific Niri settings
   - `hypr-host-settings.lua` for host-specific Hyprland settings
   - `noctalia-host-settings.toml` for Noctalia (optional)
7. Add a new entry in `flake.nix`:
   ```nix
   nixosConfigurations.<name> = mkHost "<name>" "x86_64-linux";
   ```
8. Add the host's SSH public key to `secrets/secrets.nix` and re-encrypt with `agenix --rekey`
9. Symlink repo to `/etc/nixos` if not already done
10. Deploy:
    ```bash
    sudo nixos-rebuild switch --flake .#<name>
    ```

See [hosts/README.md](hosts/README.md) for a detailed walkthrough with code examples.

## Feature Options

Optional features are gated behind `mkEnableOption` in `modules/features/`. Enable them in your host's `default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS mount options (compress=zstd:3, noatime, ssd)
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird VPN
  backup.enable = true;      # Restic backups (configurable paths, repository, exclude)
};
```

Adding a new feature: create `modules/features/<name>.nix` with `options.myfeatures.<name>.enable = lib.mkEnableOption "..."` and gate the config with `lib.mkIf cfg.enable`. It's auto-imported via `scanPaths`.

## Secrets Management

This config uses [agenix](https://github.com/ryantm/agenix) for managing encrypted secrets. Secrets are encrypted with [age](https://github.com/FiloSottile/age) using SSH host keys.

The flake passes `flakeRoot = self` via `specialArgs`, allowing modules to reference `.age` files in the repo root using absolute paths.

### Setup

1. Get your host's SSH public key:
   ```bash
   ssh-keyscan <hostname> 2>/dev/null | grep ssh-ed25519
   ```

2. Add the key to `secrets/secrets.nix`:
   ```nix
   let
     padrick = "ssh-ed25519 AAAA... root@padrick";
     jobert = "ssh-ed25519 AAAA... root@jobert";
     systems = [ padrick jobert ];
   in
   {
     "nix-access-tokens.age".publicKeys = systems;
     "netbird-setup-key.age".publicKeys = systems;
     "restic-password.age".publicKeys = systems;
   }
   ```

3. Create/edit encrypted secrets:
   ```bash
   agenix -e nix-access-tokens.age
   agenix -e netbird-setup-key.age
   agenix -e restic-password.age
   ```

4. Deploy:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

### Current Secrets

| Secret | Required By | Purpose |
|--------|-------------|---------|
| `nix-access-tokens.age` | Always | Nix/GitHub access tokens for private flakes |
| `netbird-setup-key.age` | `myfeatures.p2p.enable = true` | NetBird VPN auto-login key |

### Adding a New Host

1. Get the new host's SSH public key
2. Add the key to `secrets/secrets.nix` for each secret
3. Re-encrypt: `agenix --rekey`

### Editing Secrets

```bash
# Edit an encrypted secret (opens in $EDITOR)
agenix -e <secret-name>.age

# Decrypt a secret to stdout (for debugging)
agenix -d <secret-name>.age

# Re-encrypt all secrets after key changes
agenix --rekey
```

### Adding a New Secret

1. Create the encrypted secret file:

   ```bash
   agenix -e <secret-name>.age
   ```

   This opens your `$EDITOR` with a temp file. Write the secret, save, and quit to encrypt.

2. Declare the public keys in `secrets/secrets.nix`:

   ```nix
   {
     # ...existing secrets...
     "<secret-name>.age".publicKeys = systems;
   }
   ```

3. Re-encrypt for all hosts:

   ```bash
   agenix --rekey
   ```

4. Reference it in a NixOS module:

   ```nix
   age.secrets.<secret-name> = {
     file = "${flakeRoot}/secrets/<secret-name>.age";
     owner = "root";
     group = "root";
     mode = "0400";
   };
   ```

   Then use `config.age.secrets.<secret-name>.path` in your service config.

## Backup

The `backup` feature module (`modules/features/backup.nix`) sets up automated backups using [Restic](https://restic.net/). Enable it per host:

```nix
myfeatures.backup.enable = true;
```

### Configuration

The module supports the following options:

```nix
myfeatures.backup = {
  enable = true;
  paths = [ config.users.users.ize.home ];  # paths to back up (default: home directory)
  repository = "/mnt/backup/restic-repo";   # restic repository path
  exclude = [                                # paths to exclude
    ".cache"
    ".local/share/Trash"
    "node_modules"
    ".cargo/registry"
  ];
};
```

### Setup

1. **Enable the backup feature** in `hosts/<name>/default.nix`:

   ```nix
   myfeatures.backup.enable = true;
   ```

2. **Add the restic password to agenix.** Create `restic-password.age` in the `secrets/` directory:

   ```bash
   agenix -e restic-password.age
   ```

   Then add the key to `secrets/secrets.nix` and re-encrypt with `agenix --rekey`.

3. **Ensure the backup repository exists.** The default path is `/mnt/backup/restic-repo`. Override it via the `repository` option if using a different location (external drive, remote mount, etc.).

4. **Deploy:**

   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

**Note:** The `restic-password` secret is only required when backup is enabled. If you don't use backups, you can omit it from `secrets/secrets.nix`.

### What It Does

- **Backs up** the configured paths (default: home directory, excluding `.cache`, `.local/share/Trash`, `node_modules`, `.cargo/registry`)
- **Runs weekly** via systemd timer (`Persistent = true` catches missed runs)
- **Prunes old snapshots** automatically: keeps 7 daily, 4 weekly, 6 monthly
- **Installs `restic`** system-wide for manual operations

### Manual Operations

```bash
# List snapshots
sudo restic -r /mnt/backup/restic-repo snapshots

# Restore a specific snapshot
sudo restic -r /mnt/backup/restic-repo restore latest --target /tmp/restore

# Run a backup manually
sudo systemctl start restic-backup-home.service

# Check repository integrity
sudo restic -r /mnt/backup/restic-repo check
```

## Host-Specific Packages

**System packages** in `hosts/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # packages only needed on this host
  ];
}
```

**User packages** in `home/hosts/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # user packages only needed on this host
  ];
}
```

Shared packages live in `modules/core/packages.nix` (system) and `home/core/packages.nix` (user).

## Firewall

The firewall is enabled system-wide in `modules/security.nix` via `networking.firewall`. It blocks all inbound connections by default except for explicitly allowed ports.

### Open Ports

| Port | Protocol | Service |
|------|----------|---------|
| 51820 | UDP | NetBird (WireGuard) |

Syncthing ports are opened automatically when `myfeatures.p2p.enable = true` via `services.syncthing.openDefaultPorts`.

### Adding Ports

To open additional ports, edit `modules/security.nix`:

```nix
networking.firewall = {
  allowedTCPPorts = [ 8080 ];
  allowedUDPPorts = [ 51820 ];
  # or use ranges:
  # allowedTCPPortRanges = [ { from = 8000; to = 8100; } ];
};
```

## Optional Setup

### BTRFS: Disable COW for Steam

If you're using BTRFS, you may want to disable Copy-on-Write (COW) on the Steam downloads folder to avoid performance issues and excessive disk usage:

```bash
sudo chattr +C ~/.local/share/steam
```

This must be done before any files are written to the directory. If Steam is already installed, you'll need to move the folder, create a fresh one, apply the attribute, then move files back.

### Dual Boot with Windows

This config sets `time.hardwareClockInLocalTime = false` in `modules/core/locale.nix`, which means the hardware clock is stored in UTC. Windows assumes the hardware clock is local time by default, so time will be wrong when switching between OSes.

To fix this, run the following command in an **elevated Command Prompt** (Run as Administrator) on Windows:

```
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
```

This tells Windows to treat the hardware clock as UTC, matching Linux. Reboot Windows after running the command.

### GitHub Access Token

If you use private flakes or want to avoid GitHub rate limits:

```bash
# Create/edit the agenix secret
agenix -e nix-access-tokens.age

# Add your token in the format:
# access-tokens = github.com=ghp_GithubTokenHere
```

The token is automatically included in Nix configuration via `nix.extraOptions` in `modules/core/secrets.nix`.

### NetBird Access Token

The NetBird setup key is managed via agenix:

```bash
# Create/edit the agenix secret
agenix -e netbird-setup-key.age
```

The key is automatically decrypted to `/run/agenix/netbird-setup-key` and referenced by the NetBird service.

### Syncthing Device IDs

Syncthing device IDs are configured inline in `modules/features/p2p.nix`. To change the server device ID, edit the `devices` attrset:

```nix
services.syncthing.settings.devices = {
  "Server".id = "YOUR-DEVICE-ID";
};
```

Get a device's ID from the Syncthing GUI under Actions > Show ID.

## Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | NixOS packages (unstable) |
| `home-manager` | User environment management |
| `lanzaboote` | Secure Boot (UEFI), opt-in via `myfeatures.secureboot.enable` |
| `nixos-hardware` | NixOS hardware modules (AMD, laptop, SSD, etc.) |
| `agenix` | Encrypted secrets management (age + SSH keys) |
| `niri` | Niri Wayland compositor |
| `hyprland` | Hyprland Wayland compositor |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |
| `treefmt-nix` | Nix code formatting (nixfmt, shfmt) |

## Formatting

This config uses `treefmt-nix` for consistent code formatting. Run:

```bash
# Format all .nix files
nix fmt

# Check formatting without modifying
nix fmt -- --check
```

The formatter is configured with `nixfmt` for Nix files and `shfmt` for shell scripts.

## Scripts

| Script | Description |
|---|---|
| `scripts/output-scale` | Scale (zoom) the focused output. Supports Niri and Hyprland. Cycles between scales, or accepts `+`/`-`/specific value. Installed to `$PATH` via `home/desktop/scripts.nix`. |

## Mounting SMB Shares with Nemo

SMB network shares can be mounted directly from the Nemo file manager. `gvfs` and `nemo-with-extensions` are included in the config, and `services.gvfs` is enabled system-wide.

1. Open Nemo
2. Click `File` in the top bar and select `Connect to Server`
3. Set the server type to `Windows share`
4. Enter the server address, share name, and credentials
5. Click `Connect` -- the share appears in the sidebar and is mounted under `/run/user/1000/gvfs/`

## Custom Library

The `lib/` directory contains helper functions used throughout the config. The key helper is `scanPaths`, which auto-imports all `.nix` files in a directory (excluding `default.nix`). Adding a new module to `modules/core/`, `modules/desktop/`, `home/core/`, or `home/desktop/` only requires creating the file -- no manual import needed.

## Security

- **Firewall:** Enabled system-wide with explicit port allowlists (see [Firewall](#firewall))
- **SSH:** OpenSSH enabled with key-based auth only, root login denied (`modules/core/ssh.nix`)
- **Secrets:** agenix encrypts secrets with age using SSH host keys (see [Secrets Management](#secrets-management))
- **RealtimeKit:** `security.rtkit.enable` grants real-time scheduling to PipeWire for low-latency audio
- **Polkit:** `security.polkit.enable` for privilege escalation prompts
- **Secure Boot:** Optional via `myfeatures.secureboot.enable` (Lanzaboote)
- **nix-ld:** Enabled for LazyVim compatibility (allows running unpatched binaries)

## Nix Settings

Configured in `modules/core/system.nix`:

- `experimental-features`: `nix-command`, `flakes`, `recursive-nix`
- `warn-dirty = false`: Suppresses dirty tree warnings during rebuilds
- `auto-optimise-store = true`: Deduplicates store paths weekly
- `gc`: Automatic garbage collection weekly, deletes generations older than 14 days

## Shell

- **Primary:** Zsh with autosuggestion, syntax highlighting, completions
- **Aliases:** Shared aliases extracted to `let` binding in `home/core/shell.nix`, with zsh-only aliases (`ls`/`ll`/`lt` → `eza`) in a separate attrset
- **Prompt:** Starship with Nerd Font symbols
- **Smart cd:** Zoxide
- **Git:** LazyGit for terminal UI

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
- **Icons:** Papirus-Dark (GTK)
