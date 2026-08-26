# nixos-conf

Modular NixOS configuration using flakes and Home Manager.

## Desktops

| | |
|---|---|
| ![desktop1](_img/desktop1.png) | ![desktop2](_img/desktop2.png) |

## Structure

```
.
├── flake.nix                  # Flake entry point
├── lib/                       # Custom Nix library helpers (scanPaths, etc.)
├── hosts/                     # Per-host configurations
│   ├── padrick/               # Laptop (AMD, Wayland)
│   │   ├── default.nix        # Host NixOS config
│   │   ├── hardware-configuration.nix
│   │   ├── hardware.nix       # Host-specific hardware (CPU, graphics)
│   │   ├── packages.nix       # Host-specific system packages
│   │   ├── services.nix       # Host-specific services (TLP, UPower, etc.)
│   │   ├── secureboot.nix     # Optional: UEFI Secure Boot (Lanzaboote)
│   │   └── config/
│   │       ├── niri-hardware.kdl  # Niri monitor/output config
│   │       └── monitors.lua       # Hyprland monitor config
│   └── jobert/                # Desktop (AMD, Wayland)
│       ├── default.nix
│       ├── hardware-configuration.nix
│       ├── hardware.nix
│       ├── packages.nix
│       ├── services.nix
│       ├── secureboot.nix     # Optional: UEFI Secure Boot (Lanzaboote)
│       └── config/
│           ├── niri-hardware.kdl
│           └── monitors.lua
├── modules/                   # NixOS system modules
│   ├── core/                  # Shared by all hosts (auto-imported via scanPaths)
│   ├── desktop/               # Desktop environment (auto-imported via scanPaths)
│   └── security.nix
├── home/                      # Home Manager modules
│   ├── core/                  # Shell, git, packages, editor (auto-imported via scanPaths)
│   ├── desktop/               # GUI app configs (auto-imported via scanPaths)
│   └── hosts/                 # Host-specific HM overrides
│       ├── padrick/
│       │   ├── default.nix    # Host HM config
│       │   └── packages.nix   # Host-specific user packages
│       └── jobert/
│           ├── default.nix
│           └── packages.nix
└── config/                    # Raw dotfiles (nvim, hypr, niri, kitty, tmux)
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
3. Create `hosts/<name>/secureboot.nix` for UEFI Secure Boot (optional, see [hosts/README.md](hosts/README.md))
4. Create `hosts/<name>/config/niri-hardware.kdl` with your monitor outputs (see [hosts/README.md](hosts/README.md))
5. Create `hosts/<name>/config/monitors.lua` with Hyprland monitor config
6. Create `home/hosts/<name>/default.nix` for host-specific HM config (imports core + desktop, symlinks hardware files)
7. Create `home/hosts/<name>/packages.nix` for host-specific user packages
8. Add a new `nixosConfigurations.<name>` entry in `flake.nix`
9. Symlink repo to `/etc/nixos` if not already done
10. See [hosts/README.md](hosts/README.md) for a detailed walkthrough

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

### GitHub Access Token

If you use private flakes or want to avoid GitHub rate limits:

```bash
echo "access-tokens = github.com=ghp_GithubTokenHere" | sudo tee /etc/nix/github-token.conf
```

Read automatically via `nix.extraOptions` in `modules/core/nix.nix`.

### NetBird Access Token

To connect to a NetBird network:

```bash
sudo mkdir -p /etc/netbird
echo "your-netbird-setup-key" | sudo tee /etc/netbird/setup-key
```

Used by `services.netbird` in `modules/desktop/services.nix` for automatic login.

## Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | NixOS packages (unstable) |
| `home-manager` | User environment management |
| `lanzaboote` | Secure Boot (UEFI), opt-in per host via `hosts/<name>/secureboot.nix` |
| `nixos-hardware` | NixOS hardware modules (AMD, laptop, SSD, etc.) |
| `niri` | Niri Wayland compositor |
| `hyprland` | Hyprland Wayland compositor |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |

## Custom Library

The `lib/` directory contains helper functions used throughout the config. The key helper is `scanPaths`, which auto-imports all `.nix` files in a directory. Adding a new module to `modules/core/`, `modules/desktop/`, `home/core/`, or `home/desktop/` only requires creating the file -- no manual import needed.

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
