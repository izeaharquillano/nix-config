# nixos-conf

A multi-host NixOS configuration using flakes and Home Manager.

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
│   └── security.nix           # Neovim, nix-ld, shell aliases
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

1. Create `hosts/<name>/default.nix` and `hardware-configuration.nix`
2. Create `hosts/<name>/packages.nix` for host-specific system packages
3. Create `hosts/<name>/services.nix` for host-specific services
4. Create `hosts/<name>/hardware.nix` for host-specific hardware config (kernel params, swap, GPU)
5. Enable optional features via `myfeatures.*` options in `default.nix` (see [Feature Options](#feature-options))
6. Create `home/hosts/<name>/default.nix` for host-specific HM config (imports core + desktop)
7. Create `home/hosts/<name>/packages.nix` for host-specific user packages
8. Create `home/hosts/<name>/config/` with monitor configs:
   - `niri-host-settings.kdl` with your monitor outputs
   - `hypr-host-settings.lua` for Hyprland monitor config
   - `noctalia-host-settings.toml` for Noctalia lockscreen widget config (optional)
9. Add a new `nixosConfigurations.<name>` entry in `flake.nix` (or add to `mkHost` calls)
10. Symlink repo to `/etc/nixos` if not already done
11. See [hosts/README.md](hosts/README.md) for a detailed walkthrough

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

1. **Create the password file** before deploying:

```bash
sudo mkdir -p /etc/restic
echo "your-repo-password" | sudo tee /etc/restic/password
sudo chmod 600 /etc/restic/password
```

2. **Ensure the backup repository exists.** The default path is `/mnt/backup/restic-repo`. Override it via the `repository` option if using a different location (external drive, remote mount, etc.).

3. **Deploy:**

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

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
sudo systemctl start restic-backup-btrfs.service

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
echo "access-tokens = github.com=ghp_GithubTokenHere" | sudo tee /etc/nix/github-token.conf
```

Read automatically via `nix.extraOptions` in `modules/core/system.nix`. The config handles missing files gracefully.

### NetBird Access Token

To connect to a NetBird network:

```bash
sudo mkdir -p /etc/netbird
echo "your-netbird-setup-key" | sudo tee /etc/netbird/setup-key
```

Used by `services.netbird` in `modules/features/p2p.nix` for automatic login.

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
| `niri` | Niri Wayland compositor |
| `hyprland` | Hyprland Wayland compositor |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |
| `treefmt-nix` | Nix code formatting (nixpkgs-fmt, shfmt) |

## Formatting

This config uses `treefmt-nix` for consistent code formatting. Run:

```bash
# Format all .nix files
nix fmt

# Check formatting without modifying
nix flake check
```

The formatter is configured with `nixpkgs-fmt` for Nix files and `shfmt` for shell scripts.

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
