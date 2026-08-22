# Hosts

Each subdirectory here represents a NixOS machine. The host's `default.nix` is the entry point that imports shared modules and applies host-specific overrides.

## Current Hosts

| Host | Type | Hardware | Purpose |
|---|---|---|---|
| `padrick` | Laptop | AMD, BTRFS, Wayland | Daily use |

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
  ];

  networking.hostName = "<name>";

  # Monitor configuration for window managers (niri, hyprland).
  # Each host MUST define its monitors. The WM configs are generated from these values.
  host.monitors = [
    {
      name = "eDP-1";               # Output name (run `wlr-randr` or `niri msg outputs` to find)
      mode = "1920x1080@60";        # Resolution and refresh rate
      scale = "1.20";               # Display scale factor
      position = "auto";            # "auto" or "x=0 y=0" for explicit placement
      transform = "normal";         # "normal", "90", "180", "270", "flipped", etc.
    }
  ];

  # Host-specific overrides
  # e.g. disable laptop services on a desktop:
  # services.tlp.enable = lib.mkForce false;

  system.stateVersion = "26.05";
}
```

#### Monitor options

| Option | Type | Default | Description |
|---|---|---|---|
| `name` | string | *(required)* | Output name (`eDP-1`, `DP-1`, `HDMI-A-1`, etc.) |
| `mode` | string | *(required)* | Resolution@RefreshRate (`2560x1440@144`) |
| `scale` | string | `"1"` | Scale factor (`1`, `1.20`, `1.5`, `2`, etc.) |
| `position` | string | `"auto"` | `"auto"` or `"x=0 y=0"` for fixed position |
| `transform` | string | `"normal"` | Output rotation/transformation |

#### Multi-monitor example

```nix
host.monitors = [
  { name = "DP-1"; mode = "2560x1440@144"; scale = "1"; position = "0x0"; }
  { name = "HDMI-A-1"; mode = "1920x1080@60"; scale = "1"; position = "2560x0"; }
];
```

### 4. Add Home Manager config (optional)

Create `home/hosts/<name>.nix`:

```nix
{ pkgs, inputs, ... }:

{
  imports = [
    ../../home/core
    ../../home/desktop
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];

  # Host-specific HM overrides
}
```

### 5. Register in `flake.nix`

Add a new entry in the `outputs` attrset:

```nix
nixosConfigurations.<name> = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hosts/<name>
    lanzaboote.nixosModules.lanzaboote
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ize = import ./home/hosts/<name>.nix;
        extraSpecialArgs = { inherit inputs; };
      };
    }
  ];
};
```

### 6. Deploy

```bash
sudo nixos-rebuild switch --flake .#<name>
```
