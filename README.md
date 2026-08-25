# nixos-conf

Modular NixOS configuration using flakes and Home Manager.

## Structure

```
├── flake.nix                  # Flake entry point
├── lib/                       # Custom Nix library helpers (scanPaths, etc.)
├── hosts/                     # Per-host configurations
│   └── padrick/               # Laptop (AMD, Wayland)
│       ├── default.nix        # Host NixOS config
│       ├── hardware-configuration.nix
│       ├── packages.nix       # Host-specific system packages
│       ├── niri-hardware.kdl  # Niri monitor/output config
│       └── monitors.lua       # Hyprland monitor config
├── modules/                   # NixOS system modules
│   ├── core/                  # Shared by all hosts (auto-imported via scanPaths)
│   ├── desktop/               # Desktop environment (auto-imported via scanPaths)
│   └── security.nix           # Git, neovim, nix-ld
├── home/                      # Home Manager modules
│   ├── core/                  # Shell, git, packages, editor (auto-imported via scanPaths)
│   ├── desktop/               # GUI app configs (auto-imported via scanPaths)
│   └── hosts/                 # Host-specific HM overrides
│       └── padrick/
│           ├── default.nix    # Host HM config
│           └── packages.nix   # Host-specific user packages
└── config/                    # Raw dotfiles (nvim, hypr, niri, kitty, tmux)
```

## GitHub Access Token (Optional)

If you use private flakes or want to avoid GitHub rate limits, create a token file:

```bash
echo "access-tokens = github.com=ghp_GithubTokenHere" | sudo tee /etc/nix/github-token.conf
```

Nix reads this automatically via `nix.extraOptions` in `modules/core/nix.nix`.

## Quick Start

Symlink this repo to `/etc/nixos` (required for shell aliases like `bldflk`):

```bash
sudo ln -s /path/to/nixos-conf /etc/nixos
```

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
2. Create `hosts/<name>/packages.nix` for host-specific system packages
3. Create `hosts/<name>/niri-hardware.kdl` with your monitor outputs (see [hosts/README.md](hosts/README.md))
4. Create `hosts/<name>/monitors.lua` with hyprland monitor config
5. Create `home/hosts/<name>/default.nix` for host-specific HM config (imports core + desktop, symlinks hardware files)
6. Create `home/hosts/<name>/packages.nix` for host-specific user packages
7. Add a new `nixosConfigurations.<name>` entry in `flake.nix`
8. Symlink repo to `/etc/nixos` if not already done (required for shell aliases)
9. See [hosts/README.md](hosts/README.md) for a detailed walkthrough

## Host-Specific Packages

Add host-specific system packages in `hosts/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # packages only needed on this host
  ];
}
```

Add host-specific user packages in `home/hosts/<name>/packages.nix`:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # user packages only needed on this host
  ];
}
```

Shared packages are in `modules/core/packages.nix` (system) and `home/core/packages.nix` (user).

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

## Custom Library

The `lib/` directory contains helper functions used throughout the config. The key helper is `scanPaths`, which auto-imports all `.nix` files in a directory. This means adding a new module to `modules/core/`, `modules/desktop/`, `home/core/`, or `home/desktop/` only requires creating the file -- no manual import needed.

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
