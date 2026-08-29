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
│   ├── desktop/               # Desktop environment (auto-imported via scanPaths)
│   ├── features/              # Optional feature modules (mkEnableOption, auto-imported)
│   │   ├── btrfs.nix          # BTRFS mount options (myfeatures.btrfs.enable)
│   │   ├── secureboot.nix     # UEFI Secure Boot via Lanzaboote
│   │   ├── gaming.nix         # Steam, Gamescope, Gamemode, MangoHud
│   │   ├── vm.nix             # QEMU/KVM + virt-manager
│   │   ├── zswap.nix          # Zswap with zstd compression
│   │   └── backup.nix         # Restic backups with pruning
│   └── security.nix           # Neovim, nix-ld, shell aliases
├── home/                      # Home Manager modules
│   ├── core/                  # Shell, packages, XDG (auto-imported via scanPaths)
│   ├── desktop/               # GUI app configs (auto-imported via scanPaths)
│   └── hosts/                 # Host-specific HM overrides
│       ├── padrick/
│       │   ├── default.nix    # Imports core + desktop, symlinks host configs
│       │   ├── packages.nix
│       │   └── config/        # Host-specific dotfiles
│       │       ├── niri-host-settings.kdl
│       │       ├── hypr-host-settings.lua
│       │       └── noctalia-host-settings.toml
│       └── jobert/
│           ├── default.nix
│           ├── packages.nix
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
  backup.enable = true;      # Restic backups with pruning
};
```

Adding a new feature: create `modules/features/<name>.nix` with `options.myfeatures.<name>.enable = lib.mkEnableOption "..."` and gate the config with `lib.mkIf cfg.enable`. It's auto-imported via `scanPaths`.

## Backup

The `backup` feature module (`modules/features/backup.nix`) sets up automated backups using [Restic](https://restic.net/). Enable it per host:

```nix
myfeatures.backup.enable = true;
```

### Setup

1. **Create the password file** before deploying:

```bash
sudo mkdir -p /etc/restic
echo "your-repo-password" | sudo tee /etc/restic/password
sudo chmod 600 /etc/restic/password
```

2. **Ensure the backup repository exists.** The default path is `/mnt/backup/restic-repo`. Adjust the `repository` option in `modules/features/backup.nix` if using a different location (external drive, remote mount, etc.):

```nix
config = lib.mkIf cfg.enable {
  services.restic.backups.btrfs = {
    repository = "/mnt/backup/restic-repo";  # change this
    # ...
  };
};
```

3. **Deploy:**

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### What It Does

- **Backs up** `/home/ize` (excluding `.cache`, `.local/share/Trash`, `node_modules`, `.cargo/registry`)
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

Used by `services.netbird` in `modules/desktop/p2p.nix` for automatic login.

### Syncthing Device IDs

Syncthing device IDs are stored in `modules/desktop/syncthing-devices.nix` (gitignored). To set up:

```bash
cp modules/desktop/syncthing-devices.nix.example modules/desktop/syncthing-devices.nix
```

Then edit the file with your device IDs. Get a device's ID from the Syncthing GUI under Actions > Show ID.

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

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
