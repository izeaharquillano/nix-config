# nixos-conf

A multi-host NixOS configuration using flakes and Home Manager. A gruvbox themed (mostly) configuration implemented with Noctalia, Niri, and Hyprland. 

## Desktops

| | |
|---|---|
| ![desktop1](_img/desktop1.png) | ![desktop2](_img/desktop2.png) |

## Structure

```
.
├── flake.nix                  # Flake entry point (mkHost helper, passes hostname via specialArgs)
├── .envrc                     # direnv integration (use flake)
├── lib/                       # Custom Nix library helpers (scanPaths)
├── overlays/                  # Nixpkgs overlays (gruvbox-material-yazi)
├── pkgs/                      # Custom packages (gruvbox-material-yazi.yazi)
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
│       ├── hardware.nix       # NVIDIA driver, pinned kernel (7.2), boot params, session vars
│       ├── packages.nix
│       └── services.nix       # auto-cpufreq, UPower, systemd-resolved
├── modules/                   # NixOS system modules
│   ├── core/                  # Shared by all hosts (auto-imported via scanPaths)
│   │   ├── system.nix         # Boot, networking, nix settings, user accounts, kernelPackage option
│   │   ├── locale.nix         # Timezone, locale
│   │   ├── ssh.nix            # OpenSSH (key-based auth only)
│   │   ├── secrets.nix        # agenix secret declarations, identityPaths, token include
│   │   └── packages.nix       # Base system packages
│   ├── desktop/               # Desktop environment (auto-imported via scanPaths)
│   │   ├── greetd.nix         # Login manager (tuigreet)
│   │   ├── niri.nix           # Niri Wayland compositor
│   │   └── services.nix       # Pipewire, fonts, rtkit, bluetooth
│   ├── features/              # Optional feature modules (mkEnableOption, auto-imported)
│   │   ├── btrfs.nix          # BTRFS compression/tuning options (myfeatures.btrfs.enable)
│   │   ├── secureboot.nix     # UEFI Secure Boot via Lanzaboote
│   │   ├── gaming.nix         # Steam, Gamescope, Gamemode, MangoHud
│   │   ├── vm.nix             # QEMU/KVM + virt-manager
│   │   ├── zswap.nix          # Zswap with zstd compression
│   │   └── p2p.nix            # Syncthing + NetBird
│   └── security.nix           # Neovim, nix-ld, firewall
├── secrets/                    # Encrypted secrets (agenix)
│   ├── secrets.nix            # Public key declarations for each secret
│   ├── nix-access-tokens.age  # Nix/GitHub access tokens (encrypted)
│   └── netbird-setup-key.age  # NetBird VPN setup key (encrypted)
├── home/                      # Home Manager modules
│   ├── core/                  # Shell, packages, XDG (auto-imported via scanPaths)
│   │   ├── shell.nix          # Git, bash, zsh (shared aliases via let binding), starship, zoxide
│   │   ├── packages.nix       # CLI tools (fd, fzf, btop, ripgrep, opencode, etc.)
│   │   └── xdg.nix            # XDG user directories + portal config
│   ├── desktop/               # GUI app configs (auto-imported via scanPaths)
│   │   ├── gtk.nix            # GTK theme, cursor
│   │   ├── terminal.nix       # Kitty terminal
│   │   ├── hyprland.nix       # Hyprland config (store copy, recursive)
│   │   ├── niri.nix           # Niri config
│   │   ├── noctalia.nix       # Noctalia lockscreen/bar
│   │   ├── nvim.nix           # Neovim LazyVim config (store copy, recursive)
│   │   ├── mimeapps.nix       # Nemo desktop entry + MIME associations
│   │   ├── obsidian.nix       # Obsidian
│   │   ├── scripts.nix        # Utility scripts (output-scale)
│   │   ├── starship.nix       # Starship prompt
│   │   ├── yazi.nix           # Yazi file manager + gruvbox theme
│   │   ├── tmux.nix           # Tmux config
│   │   ├── packages.nix       # Desktop packages (ncdu, waybar, mpv, discord-ptb, nemo, etc.)
│   │   └── zen-browser.nix    # Zen Browser
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
├── config/                    # Shared raw dotfiles (nvim, hypr, niri, kitty, tmux, noctalia)
└── .github/workflows/ci.yml  # CI: flake checks + dry builds for all hosts
```

## Quick Start

```bash
# Set up secrets (first time only)
# 1. Get your host's SSH public key: ssh-keyscan <hostname> 2>/dev/null | grep ssh-ed25519
# 2. Add keys to secrets/secrets.nix
# 3. Create encrypted secrets: sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e <secret-name>.age

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

1. Create the host directory and generate hardware config:

   ```bash
   mkdir -p hosts/<name>
   mkdir -p home/hosts/<name>/config
   ```

2. On the target machine, generate the hardware config:

   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix
   ```

3. Create `hosts/<name>/default.nix` (see [hosts/README.md](hosts/README.md) for a template)
4. Create `hosts/<name>/hardware.nix`, `packages.nix`, `services.nix`
5. Create `home/hosts/<name>/default.nix` and `packages.nix`
6. Create `home/hosts/<name>/config/` with monitor configs:
   - `niri-host-settings.kdl` for host-specific Niri settings
   - `hypr-host-settings.lua` for host-specific Hyprland settings
   - `noctalia-host-settings.toml` for Noctalia (optional)
7. Add a new entry in `flake.nix`:
   ```nix
   nixosConfigurations.<name> = mkHost "<name>" "x86_64-linux";
   ```
8. Symlink the repo to `/etc/nixos` so the `bldflk` alias works:
   ```bash
   sudo ln -s /path/to/nixos-conf /etc/nixos
   ```
9. First deploy (generates SSH host keys):
   ```bash
   sudo nixos-rebuild switch --flake .#<name>
   ```
10. Grab the new host's SSH public key:
    ```bash
    ssh-keyscan <name> 2>/dev/null | grep ssh-ed25519
    ```
11. Add the key to `secrets/secrets.nix` and rekey (see [Secrets Management](#adding-a-new-host))
12. Second deploy (decrypts secrets):
    ```bash
    sudo nixos-rebuild switch --flake .#<name>
    ```

See [hosts/README.md](hosts/README.md) for a detailed walkthrough with code examples.

## Feature Options

Optional features are gated behind `mkEnableOption` in `modules/features/`. Enable them in your host's `default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS compression/tuning (compress=zstd:3, noatime, ssd)
  secureboot.enable = true;  # UEFI Secure Boot via Lanzaboote
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird VPN
};
```

Adding a new feature: create `modules/features/<name>.nix` with `options.myfeatures.<name>.enable = lib.mkEnableOption "..."` and gate the config with `lib.mkIf cfg.enable`. It's auto-imported via `scanPaths`.

## Secrets Management

This config uses [agenix](https://github.com/ryantm/agenix) for managing encrypted secrets. Secrets are encrypted with [age](https://github.com/FiloSottile/age) using SSH host keys.

The flake passes `flakeRoot = self` via `specialArgs`, allowing modules to reference `.age` files in the repo root using absolute store paths. The `age.identityPaths` option is explicitly set in `modules/core/secrets.nix` to `/etc/ssh/ssh_host_ed25519_key`.

### How It Works

1. Secrets are encrypted with age using SSH public keys from each host
2. `secrets/secrets.nix` maps each `.age` file to the public keys that can decrypt it
3. Feature modules declare `age.secrets.<name>` pointing to the `.age` file
4. At boot, agenix decrypts secrets to `/run/agenix/` with the specified mode/owner
5. Services reference the decrypted path via `config.age.secrets.<name>.path`

### Setup (First Time)

1. Get your host's SSH public key:
   ```bash
   ssh-keyscan <hostname> 2>/dev/null | grep ssh-ed25519
   ```

2. Add the key to `secrets/secrets.nix`:
   ```nix
   let
     padrick = "ssh-ed25519 AAAA... root@padrick";
     jobert = "ssh-ed25519 AAAA... root@jobert";
     systems = [ padrick jobert ];
   in
   {
     "nix-access-tokens.age".publicKeys = systems;
     "netbird-setup-key.age".publicKeys = systems;
   }
   ```

3. Create encrypted secrets:
   ```bash
   sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e nix-access-tokens.age
   sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e netbird-setup-key.age
   ```

4. Deploy:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

### Current Secrets

| Secret | Required By | Purpose |
|--------|-------------|---------|
| `nix-access-tokens.age` | Always | Nix/GitHub access tokens for private flakes |
| `netbird-setup-key.age` | `myfeatures.p2p.enable = true` | NetBird VPN auto-login key |

### Adding a New Secret

1. Create the encrypted file:
   ```bash
   sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e <secret-name>.age
   ```
   This opens `$EDITOR`. Write the secret, save, and quit to encrypt.

2. Declare public keys in `secrets/secrets.nix`:
   ```nix
   {
     # ...existing secrets...
     "<secret-name>.age".publicKeys = systems;
   }
   ```

3. Re-encrypt for all hosts:
   ```bash
   sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey
   ```

4. Reference it in a NixOS module:
   ```nix
   age.secrets.<secret-name> = {
     file = "${flakeRoot}/secrets/<secret-name>.age";
     owner = "root";
     group = "root";
     mode = "0400";
   };
   ```

   Then use `config.age.secrets.<secret-name>.path` in your service config.

### Removing a Secret

1. Remove the declaration from `secrets/secrets.nix`
2. Delete the `.age` file: `rm secrets/<secret-name>.age`
3. Remove all `age.secrets.<secret-name>` declarations from module files
4. Re-encrypt (clears orphaned references): `sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey`

### Editing Secrets

```bash
# Edit an encrypted secret (opens in $EDITOR)
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e <secret-name>.age

# Decrypt a secret to stdout (for debugging)
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -d <secret-name>.age

# Re-encrypt all secrets after key changes
sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey
```

### Adding a New Host

**Cold start (fresh install)?** SSH host keys are generated when OpenSSH starts (on first `nixos-rebuild switch`). You'll need two passes:

1. First deploy (generates SSH keys, enables services):
   ```bash
   sudo nixos-rebuild switch --flake .#newhost
   ```

2. Now grab the key:
   ```bash
   ssh-keyscan newhost 2>/dev/null | grep ssh-ed25519
   ```
   Or on the new machine directly:
   ```bash
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

3. Add the key as a binding in `secrets/secrets.nix`:
   ```nix
   let
     newhost = "ssh-ed25519 AAAA... root@newhost";
     systems = [ padrick jobert newhost ];
   in
   ```

4. Re-encrypt all secrets for the new host:
   ```bash
   sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey
   ```

5. Second deploy (decrypts secrets with the new key):
   ```bash
   sudo nixos-rebuild switch --flake .#newhost
   ```

### Resetting a Host (Lost SSH Keys)

If a host's SSH host key is lost or regenerated (e.g., after reinstalling), you need to update the key in `secrets/secrets.nix` and re-encrypt.

1. Get the new SSH public key from the host:
   ```bash
   ssh-keyscan <hostname> 2>/dev/null | grep ssh-ed25519
   ```

2. Update the key binding in `secrets/secrets.nix`:
   ```nix
   let
     # Replace the old key with the new one
     padrick = "ssh-ed25519 AAAA... root@padrick";
     systems = [ padrick jobert ];
   in
   ```

3. Re-encrypt all secrets (this re-encrypts with the new key):
   ```bash
   sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey
   ```

4. Deploy from another host or from the target if it can already build:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

**Important:** If the lost host was the only one that could decrypt a secret, you'll need to re-create the secret from another host that still has access, or from a backup of the decrypted value.

### Using the agenix CLI

The agenix CLI needs the SSH host private key to decrypt secrets. Since the key is at `/etc/ssh/ssh_host_ed25519_key` (not in `~/.ssh/`), you must specify it with `-i`:

```bash
# Via the dev shell
nix develop
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e <secret>.age

# As a flake app (no dev shell needed)
sudo nix run .#agenix -- -i /etc/ssh/ssh_host_ed25519_key -e <secret>.age
```

**Note:** The NixOS module handles decryption at boot automatically (runs as root). The `-i` flag is only needed for manual CLI operations.

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
# Create/edit the agenix secret
agenix -e nix-access-tokens.age

# Add your token in the format:
# access-tokens = github.com=ghp_GithubTokenHere
```

The token is automatically included in Nix configuration via `nix.extraOptions` in `modules/core/secrets.nix`. On first boot, an activation script ensures the token file exists before Nix reads it.

### NetBird Access Token

The NetBird setup key is managed via agenix:

```bash
# Create/edit the agenix secret
agenix -e netbird-setup-key.age
```

The key is automatically decrypted to `/run/agenix/netbird-setup-key` and referenced by the NetBird service.

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
| `agenix` | Encrypted secrets management (age + SSH keys) |
| `niri` | Niri Wayland compositor |
| `hyprland` | Hyprland Wayland compositor |
| `noctalia` | Wayland shell/bar |
| `zen-browser` | Zen Browser (Firefox-based) |
| `treefmt-nix` | Nix code formatting (nixfmt, shfmt) |

## Formatting

This config uses `treefmt-nix` for consistent code formatting. Run:

```bash
# Format all .nix files
nix fmt

# Check formatting without modifying
nix fmt -- --check
```

The formatter is configured with `nixfmt` for Nix files and `shfmt` for shell scripts.

## CI

GitHub Actions runs on push/PR to `main` (`.github/workflows/ci.yml`):

- **Flake checks**: `nix flake check --all-systems` (formatting, etc.)
- **Dry builds**: builds each host's system toplevel (`--dry-run`) to catch evaluation errors

## direnv

The `.envrc` at the repo root contains `use flake`, which automatically loads the dev shell (treefmt + agenix) when you `cd` into the repo. Requires [direnv](https://direnv.net/) to be installed and `direnv allow` run once.

## Scripts

| Script | Description |
|---|---|
| `scripts/output-scale` | Scale (zoom) the focused output. Supports Niri and Hyprland. Cycles between scales, or accepts `+`/`-`/specific value. Installed to `$PATH` via `home/desktop/scripts.nix`. |

## Overlays & Custom Packages

Custom Nix packages live in `pkgs/` and are exposed via overlays in `overlays/default.nix`. The overlay is applied globally in `flake.nix` via `nixpkgs.overlays`.

| Package | Description |
|---|---|
| `gruvbox-material-yazi` | Gruvbox Material theme for Yazi file manager (fetched from GitHub) |

To add a new custom package: create `pkgs/<name>.nix`, add it to `overlays/default.nix`, then reference it as `pkgs.<name>` in any module.

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
- **Secrets:** agenix encrypts secrets with age using SSH host keys (see [Secrets Management](#secrets-management))
- **RealtimeKit:** `security.rtkit.enable` grants real-time scheduling to PipeWire for low-latency audio
- **Polkit:** `security.polkit.enable` for privilege escalation prompts
- **Secure Boot:** Optional via `myfeatures.secureboot.enable` (Lanzaboote)
- **nix-ld:** Enabled for LazyVim compatibility (allows running unpatched binaries)
- **Kernel:** Configurable per host via `mySystem.kernelPackage` option (default: `linuxPackages_7_2`). Override in host's `hardware.nix` with `mySystem.kernelPackage = pkgs.linuxPackages_xxx;`.

## Nix Settings

Configured in `modules/core/system.nix`:

- `mySystem.kernelPackage`: Configurable kernel packages set (default: `linuxPackages_7_2`). Hosts can override via `mySystem.kernelPackage = pkgs.linuxPackages_xxx;` in their `hardware.nix`.
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

## Config Files

Config files in `config/` are consumed by Home Manager modules via `xdg.configFile` store copies. Directories with multiple files (`hypr/`, `nvim/`) use `recursive = true`. The `flakeRoot` (`self`) is passed to NixOS modules for agenix secret paths.

## Theme

- **Colors:** Gruvbox (dark) across neovim, kitty, noctalia, niri, hyprland
- **Font:** JetBrainsMono Nerd Font
- **Icons:** Papirus-Dark (GTK)
