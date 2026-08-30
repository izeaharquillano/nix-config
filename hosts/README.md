# Hosts

Each subdirectory here represents a NixOS machine. The host's `default.nix` is the entry point that imports shared modules and applies host-specific overrides.

## Current Hosts

| Host | Type | Hardware | Purpose |
|---|---|---|---|
| `padrick` | Laptop | AMD, BTRFS, Wayland | Daily use |
| `jobert` | Gaming Laptop | AMD + NVIDIA, BTRFS, Wayland | Work/gaming |

## Hardware Config Pattern

Each host directory contains hardware-specific config files:

```
hosts/padrick/
├── default.nix                 # Host NixOS config (imports modules, enables features)
├── hardware-configuration.nix  # Auto-generated hardware scan
├── hardware.nix                # Kernel params, swap, VA-API
├── packages.nix                # Host-specific system packages
└── services.nix                # TLP, UPower, mic-mute LED sync

hosts/jobert/
├── default.nix
├── hardware-configuration.nix
├── hardware.nix                # NVIDIA driver, pinned kernel (7.2), boot params, session vars
├── packages.nix
└── services.nix                # auto-cpufreq, UPower, systemd-resolved
```

Shared features (BTRFS, Secure Boot, gaming, virtualisation, P2P) are configured via `myfeatures.*` options in each host's `default.nix`. Feature modules live in `modules/features/` and are auto-imported via `scanPaths`.

### padrick: Daily Use ThinkPad

`padrick` enables core features in `hosts/padrick/default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS mount options
  secureboot.enable = true;  # UEFI Secure Boot
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird
};
```

### jobert: Gaming & Virtualization

`jobert` enables gaming and VM features via options in `hosts/jobert/default.nix`:

```nix
myfeatures = {
  btrfs.enable = true;       # BTRFS mount options
  secureboot.enable = true;  # UEFI Secure Boot
  zswap.enable = true;       # Zswap with zstd compression
  p2p.enable = true;         # Syncthing + NetBird
  vm.enable = true;          # QEMU/KVM + virt-manager
  gaming.enable = true;      # Steam, Gamescope, Gamemode, MangoHud
};
```

The gaming module configures:

- **Steam** with remote play and dedicated server firewall rules
- **Proton GE** (`proton-ge-bin`) as an extra compatibility layer
- **Gamescope** (Wayland gamecope session, `--rt`)
- **Gamemode** for automatic CPU/GPU performance tuning
- **MangoHud** and **GOverlay** for FPS overlay and Vulkan/OpenGL settings

`jobert` also has NVIDIA-specific hardware config in `hosts/jobert/hardware.nix` (pinned kernel `linuxPackages_7_2` with `lib.mkForce`, open driver, VA-API, Wayland env vars, 32-bit OpenGL).

Host-specific dotfiles (niri, hyprland, noctalia settings) live in `home/hosts/<name>/config/` and are symlinked by the host-specific HM file.

### niri-host-settings.kdl

Plain KDL file for host-specific Niri settings. Niri's `config.kdl` uses `include "./niri-host-settings.kdl"` to pull this in. Typically contains monitor/output configurations, but can include any host-specific Niri settings.

```kdl
output "eDP-1" {
    mode "1920x1080@60"
    scale 1.20
    transform "normal"
}

output "DP-1" {
    mode "2560x1440@144"
    scale 1
    transform "normal"
    position x=1920 y=0
}

// Optional: pin workspaces to specific outputs
workspace "1terminal" { open-on-output "eDP-1"; }
workspace "2browser" { open-on-output "DP-1"; }
```

### hypr-host-settings.lua

Lua file for host-specific Hyprland settings. Used via `require("hypr-host-settings")` in the main Hyprland config. Typically contains monitor configurations, but can include any host-specific Hyprland settings.

```lua
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.20",
})

hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@144",
    position = "0x0",
    scale    = "1",
})
```

## Adding a New Host

### 1. Create the host directory

```bash
mkdir -p hosts/<name>
mkdir -p home/hosts/<name>/config
```

### 2. Add hardware configuration

On the target machine, generate it:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Or copy from an existing host and modify.

### 3. Create `hosts/<name>/default.nix`

```nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/core              # Base system config (includes SSH)
    ../../modules/desktop           # Desktop environment (skip for servers)
    ../../modules/security.nix      # Neovim, nix-ld, firewall
    ../../modules/features          # Optional feature modules (auto-imported)
    ./hardware-configuration.nix
    ./packages.nix                  # Host-specific system packages
    ./services.nix                  # Host-specific services
    ./hardware.nix                  # Host-specific hardware (kernel params, swap, GPU)
  ];

  networking.hostName = "<name>";

  # Enable optional features
  myfeatures = {
    btrfs.enable = true;          # BTRFS mount options
    secureboot.enable = true;     # UEFI Secure Boot
    zswap.enable = true;          # Zswap with zstd compression
    p2p.enable = true;            # Syncthing + NetBird VPN
    # vm.enable = true;           # QEMU/KVM
    # gaming.enable = true;       # Steam, Gamescope, etc.
  };

  system.stateVersion = "26.05";
}
```

### 4. Create `hosts/<name>/services.nix`

Host-specific services that differ from the shared desktop modules. For laptops, include power management and hardware-specific services:

```nix
{ pkgs, lib, ... }:

{
  services.resolved.enable = true;  # systemd-resolved for DNS

  # Power management (disable power-profiles-daemon when using TLP)
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 5;
    percentageAction = 2;
    criticalPowerAction = "PowerOff";
  };
}
```

For desktops, this file can be minimal or omitted entirely.

### Disabling Services Per Host

Services enabled in `modules/core/` or `modules/desktop/` apply to all hosts via `scanPaths`. To disable a service on a specific host, use `lib.mkForce` in the host's `default.nix`:

```nix
{ lib, ... }:

{
  # Disable syncthing and netbird (modules/features/p2p.nix)
  services.syncthing.enable = lib.mkForce false;
  services.netbird.enable = lib.mkForce false;

  # Disable laptop services on a desktop
  services.tlp.enable = lib.mkForce false;
}
```

### 5. Create host-specific config files

Create `home/hosts/<name>/config/niri-host-settings.kdl` for host-specific Niri settings:

```kdl
output "eDP-1" {
    mode "1920x1080@60"
    scale 1.20
    transform "normal"
}
```

Create `home/hosts/<name>/config/hypr-host-settings.lua` for host-specific Hyprland settings:

```lua
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.20",
})
```

Optionally, create `home/hosts/<name>/config/noctalia-host-settings.toml` for Noctalia host specific configurations. If present, it is written to `host-settings.toml` in `~/.config/noctalia/` by `home/desktop/noctalia.nix`.

### 6. Add Home Manager config

Create `home/hosts/<name>/default.nix`:

```nix
{ config, inputs, ... }:

let
  repoDir = "${config.home.homeDirectory}/nixos-conf";
in
{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-host-settings.kdl".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/hosts/<name>/config/niri-host-settings.kdl";
  xdg.configFile."hypr/hypr-host-settings.lua".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/hosts/<name>/config/hypr-host-settings.lua";
}
```

### 7. Register in `flake.nix`

Add a new `mkHost` call in the `outputs` attrset:

```nix
nixosConfigurations.<name> = mkHost "<name>" "x86_64-linux";
```

The `mkHost` helper handles all the boilerplate (system, specialArgs, home-manager config). See the root README for details.

### 8. Set up Secure Boot (optional, first-time only)

If you enabled `myfeatures.secureboot.enable` in your host's `default.nix`, enroll Secure Boot keys before the first deploy:

```bash
# Create and enroll keys (interactive, requires physical presence)
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft

# Verify enrollment
sbctl status
```

This only needs to be done once per machine. The keys are stored in `/var/lib/sbctl`.

To skip Secure Boot, omit `secureboot.enable = true` (or set it to `false`). The host will use plain systemd-boot.

### 9. First deploy (generates SSH host keys)

```bash
sudo nixos-rebuild switch --flake .#<name>
```

### 10. Add host key to secrets

SSH host keys are generated on first boot. Grab the key:

```bash
ssh-keyscan <name> 2>/dev/null | grep ssh-ed25519
```

Add it to `secrets/secrets.nix` and rekey (see [Secrets Management](../README.md#adding-a-new-host) in the main README).

### 11. Second deploy (decrypts secrets)

```bash
sudo nixos-rebuild switch --flake .#<name>
```

## BTRFS: Disable COW for Steam

If your host uses BTRFS (both `padrick` and `jobert` do), you may want to disable Copy-on-Write (COW) on the Steam downloads folder to avoid performance issues and excessive disk usage:

```bash
sudo chattr +C ~/.local/share/steam
```

This must be done before any files are written to the directory. If Steam is already installed, you'll need to move the folder, create a fresh one, apply the attribute, then move files back.

## GitHub Access Token (Optional)

If you use private flakes or want to avoid GitHub rate limits, add your token via agenix:

```bash
sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e nix-access-tokens.age
```

Add the token in the format: `access-tokens = github.com=ghp_GithubTokenHere`

The token is automatically included in Nix configuration via `nix.extraOptions` in `modules/core/secrets.nix`.
