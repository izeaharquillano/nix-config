# Hosts

Each subdirectory here represents a NixOS machine. The host's `default.nix` is the entry point that imports shared modules and applies host-specific overrides.

## Current Hosts

| Host | Type | Hardware | Purpose |
|---|---|---|---|
| `padrick` | Laptop | AMD, BTRFS, Wayland | Daily use |

## Hardware Config Pattern

Each host directory contains hardware-specific config files:

```
hosts/padrick/
├── default.nix                 # Host NixOS config (imports modules)
├── hardware-configuration.nix  # Auto-generated hardware scan
├── hardware.nix                # Host-specific hardware (CPU microcode, graphics)
├── packages.nix                # Host-specific system packages
├── services.nix                # Host-specific services (TLP, UPower, etc.)
├── niri-hardware.kdl           # Niri monitor/output config (KDL format)
└── monitors.lua                # Hyprland monitor config (Lua format)
```

### niri-hardware.kdl

Plain KDL file with `output` blocks defining monitor settings. Niri's `config.kdl` uses `include "./niri-hardware.kdl"` to pull this in. Run `niri msg outputs` to find output names.

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

### monitors.lua

Lua file defining monitor configs for Hyprland. Used via `require("monitors")` in the main Hyprland config.

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
mkdir hosts/<name>
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
  # Disable netbird (modules/core/netbird.nix)
  services.netbird.enable = lib.mkForce false;

  # Disable syncthing (modules/desktop/services.nix)
  services.syncthing.enable = lib.mkForce false;

  # Disable laptop services on a desktop
  services.tlp.enable = lib.mkForce false;
}
```

### 5. Create monitor config files

Create `hosts/<name>/niri-hardware.kdl` with your display outputs:

```kdl
output "eDP-1" {
    mode "1920x1080@60"
    scale 1.20
    transform "normal"
}
```

Create `hosts/<name>/monitors.lua` for Hyprland:

```lua
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "1.20",
})
```

### 6. Add Home Manager config

Create `home/hosts/<name>/default.nix`:

```nix
{ config, inputs, ... }:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ../../core
    ../../desktop
    ./packages.nix
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  # Symlink host-specific hardware configs into ~/.config/
  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nixos-conf/hosts/<name>/niri-hardware.kdl";

  xdg.configFile."hypr/monitors.lua".source =
    mkSymlink "${config.home.homeDirectory}/nixos-conf/hosts/<name>/monitors.lua";
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
    lanzaboote.nixosModules.lanzaboote
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ize = import ./home/hosts/<name>;
        extraSpecialArgs = { inherit inputs mylib; };
      };
    }
  ];
};
```

### 8. Set up Secure Boot (first-time only)

On a new machine, enroll Secure Boot keys before the first deploy:

```bash
# Create and enroll keys (interactive, requires physical presence)
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft

# Verify enrollment
sbctl status
```

This only needs to be done once per machine. The keys are stored in `/var/lib/sbctl`.

### 9. Symlink repo to /etc/nixos

Required for shell aliases (`bldflk`, `bldswc`, etc.) to work:

```bash
sudo ln -s /path/to/nixos-conf /etc/nixos
```

### 10. Deploy

```bash
sudo nixos-rebuild switch --flake .#<name>
```

## GitHub Access Token (Optional)

If you use private flakes or want to avoid GitHub rate limits, create a token file before building:

```bash
echo "access-tokens = github.com=ghp_GithubTokenHere" | sudo tee /etc/nix/github-token.conf
```

Nix reads this automatically via `nix.extraOptions` in `modules/core/nix.nix`.
