# Home Manager Modules

User-level configuration managed by Home Manager.

## Structure

```
home/
├── core/                    # Shared across all hosts
│   ├── default.nix          # Aggregator + stateVersion, username
│   ├── shell.nix            # Bash, zoxide, cursor theme, aliases
│   ├── git.nix              # Git user name/email
│   └── packages.nix         # CLI tools (fd, fzf, btop, ripgrep, etc.) + npm
├── desktop/                 # Desktop/GUI app configs
│   ├── default.nix          # Aggregator
│   ├── ghostty.nix          # Ghostty terminal (xdg.configFile)
│   ├── hyprland.nix         # Hyprland config files
│   ├── niri.nix             # Niri config files
│   ├── noctalia.nix         # Noctalia bar/shell
│   ├── nvim.nix             # Neovim LazyVim config (xdg.configFile)
│   ├── yazi.nix             # Yazi file manager + gruvbox theme
│   ├── tmux.nix             # Tmux config
│   ├── waybar.nix           # Waybar + desktop packages
│   ├── zen-browser.nix      # Zen Browser
│   └── terminal.nix         # Ghostty package
└── hosts/
    └── padrick.nix          # Host-specific HM: imports core + desktop
```

## Module Types

- **`core/`** - Essential user config (shell, git, packages). Always imported.
- **`desktop/`** - GUI applications and dotfiles. Only for desktop hosts.
- **`hosts/<name>.nix`** - Host-specific overrides and flake input imports.

## How It Works

The host's HM entry point (`home/hosts/<name>.nix`) imports `core/` and `desktop/`, plus any flake module inputs (niri, noctalia, zen-browser).

Raw dotfiles in `config/` are consumed via `xdg.configFile` in the desktop modules.

## Adding a Module

1. Create a `.nix` file in `home/core/` or `home/desktop/`
2. Add it to the corresponding `default.nix` imports list
3. Follow the Home Manager module pattern:

```nix
{ pkgs, ... }:

{
  programs.<name> = {
    enable = true;
    # options...
  };
}
```

## Adding a Dotfile

1. Place the config file in `config/<app>/`
2. Create or update a module in `home/desktop/`:

```nix
{ ... }:

{
  xdg.configFile."app/config".source = ../../config/app/config;
}
```

For directories, use `recursive = true`:

```nix
xdg.configFile."app" = {
  source = ../../config/app;
  recursive = true;
};
```

## Host-Specific Overrides

In `home/hosts/<name>.nix`, add or override settings after the imports:

```nix
{ pkgs, inputs, ... }:

{
  imports = [
    ../../home/core
    ../../home/desktop
  ];

  # Host-specific overrides
  home.packages = with pkgs; [
    extra-package-only-for-this-host
  ];
}
```
