# nixos-conf

Modular NixOS configuration using flakes and Home Manager.

## Structure

```
├── flake.nix                  # Flake entry point
├── hosts/                     # Per-host configurations
│   └── padrick/               # Laptop (AMD, Wayland)
├── modules/                   # NixOS system modules
│   ├── core/                  # Shared by all hosts
│   ├── desktop/               # Desktop environment (WMs, greetd, fonts, services)
│   │   └── monitors.nix       # Per-host monitor options (host.monitors)
│   └── security.nix           # Git, neovim, nix-ld
├── home/                      # Home Manager modules
│   ├── core/                  # Shell, git, packages, editor
│   ├── desktop/               # GUI app configs (generates WM monitor configs from osConfig)
│   └── hosts/                 # Host-specific HM overrides
└── config/                    # Raw dotfiles (nvim, hypr, niri, ghostty, tmux)
```

## Quick Start

Deploy for padrick:

```bash
sudo nixos-rebuild switch --flake .#padrick
```

Build without switching:

```bash
nix build .#nixosConfigurations.padrick.config.system.build.toplevel
```

## Adding a New Host

1. Create `hosts/<name>/default.nix` and `hardware-configuration.nix`
2. Set `host.monitors` with your display outputs (see [hosts/README.md](hosts/README.md))
3. Optionally create `home/hosts/<name>.nix` for host-specific HM config
4. Add a new `nixosConfigurations.<name>` entry in `flake.nix`
5. See [hosts/README.md](hosts/README.md) for details

## Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | NixOS packages (unstable) |
| `home-manager` | User environment management |
| `lanzaboote` | Secure Boot (UEFI) |
| `niri` | Niri Wayland compositor |
| `hyprland` | Hyprland Wayland compositor |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |

## Theme

- **Colors:** Gruvbox (dark) across neovim, ghostty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
