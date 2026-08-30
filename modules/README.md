# NixOS Modules

System-level NixOS configuration split into reusable modules.

## Structure

```
modules/
├── core/                # Shared by ALL hosts (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (auto-imported via scanPaths)
│   ├── system.nix       # Boot, networking, nix settings, user accounts
│   ├── locale.nix       # Timezone, i18n/locale settings, hardware clock (UTC)
│   ├── ssh.nix          # OpenSSH (key-based auth only, root login denied)
│   ├── secrets.nix      # agenix secret declarations (age key config, secrets)
│   └── packages.nix     # System-wide packages
├── desktop/             # Desktop environment (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (auto-imported via scanPaths)
│   ├── greetd.nix       # Login manager (tuigreet)
│   ├── niri.nix         # Niri Wayland compositor
│   └── services.nix     # blueman, fwupd, pipewire, bluetooth, gvfs, zsh, hyprland, fonts
├── features/            # Optional feature modules (mkEnableOption, auto-imported)
│   ├── default.nix      # Aggregator (auto-imported via scanPaths)
│   ├── btrfs.nix        # BTRFS mount options (myfeatures.btrfs.enable)
│   ├── secureboot.nix   # UEFI Secure Boot (myfeatures.secureboot.enable)
│   ├── vm.nix           # QEMU/KVM + virt-manager (myfeatures.vm.enable)
│   ├── gaming.nix       # Steam, Gamescope, Gamemode (myfeatures.gaming.enable)
│   ├── zswap.nix        # Zswap with zstd compression (myfeatures.zswap.enable)
│   ├── p2p.nix          # Syncthing + NetBird (myfeatures.p2p.enable)
│   └── backup.nix       # Restic backups (myfeatures.backup.enable)
└── security.nix         # Neovim, nix-ld, firewall
```

## Module Types

- **`core/`** - Base system config (boot, networking, nix, users, SSH) every host needs. Always imported.
  - `locale.nix` sets `time.hardwareClockInLocalTime = false` (RTC in UTC). See the main README for dual-boot Windows instructions.
  - `ssh.nix` enables OpenSSH with key-based auth only.
- **`desktop/`** - GUI/desktop config. Only imported by desktop hosts.
- **`features/`** - Optional features gated behind `mkEnableOption`. Auto-imported via `scanPaths`; enable per host with `myfeatures.<name>.enable`.
- **`security.nix`** - Neovim, nix-ld, firewall. Imported separately for flexibility.

## Feature Options

Enable optional features in `hosts/<name>/default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS mount options (compress=zstd:3, noatime, ssd)
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird VPN
  backup.enable = true;      # Restic backups with pruning
};
```

### Backup Feature

The `backup` feature module sets up automated backups using Restic. See the [main README](../README.md#backup) for full setup instructions.

Key details:
- Backs up home directory weekly
- Excludes `.cache`, `.local/share/Trash`, `node_modules`, `.cargo/registry`
- Prunes to 7 daily, 4 weekly, 6 monthly snapshots
- Requires the `restic-password` secret (create with `agenix -e restic-password.age`) and a repository path (default: `/mnt/backup/restic-repo`)

### P2P Feature

The `p2p` feature module (`modules/features/p2p.nix`) configures Syncthing and NetBird. Enable it per host:

```nix
myfeatures.p2p.enable = true;
```

This enables:
- **Syncthing** with default ports open for sync and discovery
- **NetBird** VPN with automatic login via setup key (`/etc/netbird/setup-key`)

Syncthing paths use `config.users.users.ize.home` dynamically rather than hardcoded paths.

### Adding a new feature

Create `modules/features/<name>.nix`. It's auto-imported by `scanPaths`:

```nix
{ pkgs, lib, config, ... }:

let
  cfg = config.myfeatures.<name>;
in
{
  options.myfeatures.<name> = {
    enable = lib.mkEnableOption "Description of the feature";
  };

  config = lib.mkIf cfg.enable {
    # your config here
  };
}
```

## Overriding Modules Per Host

In `hosts/<name>/default.nix`, use `lib.mkForce` or `lib.mkDefault` to override:

```nix
{ lib, ... }:

{
  # Disable syncthing and netbird (modules/features/p2p.nix)
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;

  # Override hostname
  networking.hostName = lib.mkDefault "my-host";
}
```
