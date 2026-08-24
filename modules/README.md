# NixOS Modules

System-level NixOS configuration split into reusable modules.

## Structure

```
modules/
├── core/                # Shared by ALL hosts
│   ├── default.nix      # Aggregator (imports all core modules)
│   ├── boot.nix         # Bootloader (lanzaboote), kernel, swap
│   ├── networking.nix   # NetworkManager
│   ├── locale.nix       # Timezone, i18n/locale settings
│   ├── nix.nix          # Nix settings (flakes, netrc)
│   ├── packages.nix     # System-wide packages
│   └── users.nix        # User accounts and groups
├── desktop/             # Desktop environment (import by desktop hosts)
│   ├── default.nix      # Aggregator (imports all desktop modules)
│   ├── greetd.nix       # Login manager (tuigreet)
│   ├── niri.nix         # Niri Wayland compositor
│   ├── hyprland.nix     # Hyprland Wayland compositor
│   ├── fonts.nix        # System fonts (JetBrainsMono NF)
│   ├── services.nix     # blueman, tlp, upower, bluetooth, mic-mute-led
│   ├── hardware.nix     # Laptop-specific (battery, power management)
│   └── zsh.nix          # Zsh system-level config
└── security.nix         # Git, neovim, nix-ld, shell aliases
```

## Module Types

- **`core/`** - Base system config every host needs. Always imported.
- **`desktop/`** - GUI/desktop config. Only imported by desktop hosts.
- **`security.nix`** - Shared tools (git, editor). Imported separately for flexibility.

## Adding a Module

1. Create a `.nix` file in the appropriate directory
2. Add it to the corresponding `default.nix` imports list
3. Follow the standard NixOS module pattern:

```nix
{ config, pkgs, lib, ... }:

{
  # your config here
}
```

## Overriding Modules Per Host

In `hosts/<name>/default.nix`, use `lib.mkForce` or `lib.mkDefault` to override:

```nix
{ lib, ... }:

{
  # Disable TLP on a desktop (no battery)
  services.tlp.enable = lib.mkForce false;

  # Override hostname
  networking.hostName = lib.mkDefault "my-host";
}
```

## Adding a New Desktop Module

1. Create `modules/desktop/<name>.nix`
2. Add the import to `modules/desktop/default.nix`:

```nix
imports = [
  # ... existing imports
  ./.<name>.nix
];
```
