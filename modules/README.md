# NixOS Modules

System-level NixOS configuration split into reusable modules.

## Structure

```
modules/
├── core/                # Shared by ALL hosts (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (imports all core modules)
│   ├── system.nix       # Boot, networking, nix settings, user accounts
│   ├── locale.nix       # Timezone, i18n/locale settings, hardware clock (UTC)
│   └── packages.nix     # System-wide packages
├── desktop/             # Desktop environment (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (imports all desktop modules)
│   ├── greetd.nix       # Login manager (tuigreet)
│   ├── niri.nix         # Niri Wayland compositor
│   ├── p2p.nix          # Syncthing + Netbird (disable per host with mkForce)
│   ├── services.nix     # blueman, fwupd, pipewire, bluetooth, gvfs, polkit, zsh, hyprland, fonts
│   └── hardware.nix     # Laptop-specific (battery, power management)
├── features/            # Optional feature modules (mkEnableOption, auto-imported)
│   ├── default.nix      # Aggregator (auto-imported via scanPaths)
│   ├── btrfs.nix        # BTRFS mount options (myfeatures.btrfs.enable)
│   ├── secureboot.nix   # UEFI Secure Boot (myfeatures.secureboot.enable)
│   ├── vm.nix           # QEMU/KVM + virt-manager (myfeatures.vm.enable)
│   └── gaming.nix       # Steam, Gamescope, Gamemode (myfeatures.gaming.enable)
└── security.nix         # Git, neovim, nix-ld, shell aliases
```

## Module Types

- **`core/`** - Base system config (boot, networking, nix, users) every host needs. Always imported.
  - `locale.nix` sets `time.hardwareClockInLocalTime = false` (RTC in UTC). See the main README for dual-boot Windows instructions.
- **`desktop/`** - GUI/desktop config. Only imported by desktop hosts.
- **`features/`** - Optional features gated behind `mkEnableOption`. Auto-imported via `scanPaths`; enable per host with `myfeatures.<name>.enable`.
- **`security.nix`** - Shared tools (git, editor). Imported separately for flexibility.

## Feature Options

Enable optional features in `hosts/<name>/default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS mount options (compress=zstd:3, noatime, ssd)
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
};
```

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
  # Disable syncthing and netbird (modules/desktop/p2p.nix)
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;

  # Override hostname
  networking.hostName = lib.mkDefault "my-host";
}
```
