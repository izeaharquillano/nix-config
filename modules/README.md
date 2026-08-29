# NixOS Modules

System-level NixOS configuration split into reusable modules.

## Structure

```
modules/
├── core/                # Shared by ALL hosts (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (imports all core modules)
│   ├── boot.nix         # Bootloader (systemd-boot), kernel
│   ├── networking.nix   # NetworkManager
│   ├── locale.nix       # Timezone, i18n/locale settings
│   ├── nix.nix          # Nix settings (flakes, netrc)
│   ├── packages.nix     # System-wide packages
│   └── users.nix        # User accounts and groups
├── desktop/             # Desktop environment (auto-imported via scanPaths)
│   ├── default.nix      # Aggregator (imports all desktop modules)
│   ├── greetd.nix       # Login manager (tuigreet)
│   ├── niri.nix         # Niri Wayland compositor
│   ├── hyprland.nix     # Hyprland Wayland compositor
│   ├── fonts.nix        # System fonts (JetBrainsMono NF)
│   ├── p2p.nix          # Syncthing + Netbird (disable per host with mkForce)
│   ├── services.nix     # blueman, fwupd, pipewire, bluetooth, gvfs, polkit
│   ├── hardware.nix     # Laptop-specific (battery, power management)
│   └── zsh.nix          # Zsh system-level config
├── btrfs.nix            # BTRFS mount options (compress, noatime, ssd)
├── secureboot.nix       # UEFI Secure Boot (Lanzaboote), opt-in per host
├── vm.nix               # QEMU/KVM + virt-manager, opt-in per host
└── security.nix         # Git, neovim, nix-ld, shell aliases
```

## Module Types

- **`core/`** - Base system config every host needs. Always imported.
- **`desktop/`** - GUI/desktop config. Only imported by desktop hosts.
- **`btrfs.nix`** - BTRFS mount options. Imported by hosts using BTRFS.
- **`secureboot.nix`** - Lanzaboote for UEFI Secure Boot. Opt-in per host.
- **`vm.nix`** - QEMU/KVM virtualisation. Opt-in per host.
- **`security.nix`** - Shared tools (git, editor). Imported separately for flexibility.

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
