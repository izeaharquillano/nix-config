# Hosts

Each subdirectory here represents a NixOS machine. The host's `default.nix` is the entry point that imports shared modules and applies host-specific overrides.

## Current Hosts

| Host | Type | Hardware | Purpose |
|---|---|---|---|
| `padrick` | Laptop | AMD, BTRFS, Wayland | Daily use |
| `jobert` | Gaming Laptop | AMD, BTRFS, Wayland | Work/gaming |

## Hardware Config Pattern

Each host directory contains hardware-specific config files:

```
hosts/padrick/
├── default.nix                 # Host NixOS config (imports modules)
├── hardware-configuration.nix  # Auto-generated hardware scan
├── hardware.nix                # Host-specific hardware (CPU, graphics)
├── disk.nix                    # Disk/partition config
├── packages.nix                # Host-specific system packages
├── services.nix                # Host-specific services (TLP, UPower, etc.)
└── secureboot.nix              # Optional: UEFI Secure Boot (Lanzaboote)
```

Host-specific dotfiles (monitor configs, noctalia settings) live in `home/hosts/<name>/config/` and are symlinked by the host-specific HM file.

### niri-host-settings.kdl

Plain KDL file with `output` blocks defining monitor settings. Niri's `config.kdl` uses `include "./niri-host-settings.kdl"` to pull this in. Run `niri msg outputs` to find output names.

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

Lua file defining monitor configs for Hyprland. Used via `require("hypr-host-settings")` in the main Hyprland config.

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
    ../../modules/core              # Base system config
    ../../modules/desktop           # Desktop environment (skip for servers)
    ../../modules/security.nix      # Git, neovim, nix-ld
    ./hardware-configuration.nix
    ./packages.nix                  # Host-specific system packages
    ./services.nix                  # Host-specific services
    ./secureboot.nix                # Optional: UEFI Secure Boot (omit for plain systemd-boot)
  ];

  networking.hostName = "<name>";

  # Host-specific overrides
  # e.g. disable laptop services on a desktop:
  # services.tlp.enable = lib.mkForce false;

  system.stateVersion = "26.05";
}
```

### 4. Create `hosts/<name>/services.nix`

Host-specific services that differ from the shared desktop modules. For laptops, include power management and hardware-specific services:

```nix
{ pkgs, ... }:

{
  # Power management (disable power-profiles-daemon when using TLP)
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };

  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 5;
    percentageAction = 2;
    criticalPowerAction = "PowerOff";
  };

  # Add host-specific udev rules, systemd services, etc.
}
```

For desktops, this file can be minimal or omitted entirely.

### Disabling Services Per Host

Services enabled in `modules/core/` or `modules/desktop/` apply to all hosts via `scanPaths`. To disable a service on a specific host, use `lib.mkForce` in the host's `default.nix`:

```nix
{ lib, ... }:

{
  # Disable netbird (modules/desktop/services.nix)
  services.netbird.enable = lib.mkForce false;

  # Disable syncthing (modules/desktop/services.nix)
  services.syncthing.enable = lib.mkForce false;

  # Disable laptop services on a desktop
  services.tlp.enable = lib.mkForce false;
}
```

### 5. Create monitor config files

Create `home/hosts/<name>/config/niri-host-settings.kdl` with your display outputs:

```kdl
output "eDP-1" {
    mode "1920x1080@60"
    scale 1.20
    transform "normal"
}
```

Create `home/hosts/<name>/config/hypr-host-settings.lua` for Hyprland:

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

{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/niri-host-settings.kdl".source = ./config/niri-host-settings.kdl;

  xdg.configFile."hypr/hypr-host-settings.lua".source = ./config/hypr-host-settings.lua;
}
```

### 7. Register in `flake.nix`

Add a new entry in the `outputs` attrset:

```nix
nixosConfigurations.<name> = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs mylib; };
  modules = [
    ./hosts/<name>
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ize = import ./home/hosts/<name>;
        extraSpecialArgs = { inherit inputs mylib; hostname = "<name>"; };
      };
    }
  ];
};
```

### 8. Set up Secure Boot (optional, first-time only)

If you created `hosts/<name>/secureboot.nix`, enroll Secure Boot keys before the first deploy:

```bash
# Create and enroll keys (interactive, requires physical presence)
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft

# Verify enrollment
sbctl status
```

This only needs to be done once per machine. The keys are stored in `/var/lib/sbctl`.

To skip Secure Boot, simply omit `./secureboot.nix` from your host's imports. The host will use plain systemd-boot.

### 9. Symlink repo to /etc/nixos

Required for shell aliases (`bldflk`, `bldswc`, etc.) to work:

```bash
sudo ln -s /path/to/nixos-conf /etc/nixos
```

### 10. Deploy

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

If you use private flakes or want to avoid GitHub rate limits, create a token file before building:

```bash
echo "access-tokens = github.com=ghp_GithubTokenHere" | sudo tee /etc/nix/github-token.conf
```

Nix reads this automatically via `nix.extraOptions` in `modules/core/nix.nix`.
