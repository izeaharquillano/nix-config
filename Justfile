# Task runner; see https://just.systems/

set shell := ["bash", "-euo", "pipefail", "-c"]

repo_root := justfile_directory()

# List all available recipes
default:
    @just --list

# ─── Nix Core ───────────────────────────────────────────────────────────────

# Update all flake inputs
[group('nix')]
update:
    nix flake update

# Update a specific flake input (e.g. just update-input nixpkgs)
[group('nix')]
update-input input:
    nix flake update {{input}}

# Run all flake checks
[group('nix')]
check:
    nix flake check --all-systems

# Format all .nix files
[group('nix')]
fmt:
    nix fmt

# Check formatting without modifying files
[group('nix')]
fmt-check:
    nix fmt -- --fail-on-change

# Enter a nix repl with the flake
[group('nix')]
repl:
    nix repl flake:

# Garbage collect old generations (system-wide + user, 30-day retention)
[group('nix')]
gc:
    sudo nix-collect-garbage --delete-older-than 30d
    nix-collect-garbage --delete-older-than 30d

# Wipe all generation history (system + home-manager)
[group('nix')]
clean:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system
    nix profile wipe-history --profile "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"

# Delete all generations except current + garbage collect (system + home-manager)
[group('nix')]
purge:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system
    nix profile wipe-history --profile "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Deduplicate identical files in the nix store via hard links
[group('nix')]
optimise:
    sudo nix store optimise

# Enter a dev shell with common tools
[group('nix')]
shell:
    nix shell nixpkgs#git nixpkgs#neovim

# ─── Deploy ─────────────────────────────────────────────────────────────────

# Build without switching (defaults to current hostname: just build [host])
[group('deploy')]
build host=shell('hostname'):
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel

# Build and switch (defaults to current hostname: just switch [host])
[group('deploy')]
switch host=shell('hostname'):
    sudo nixos-rebuild switch --flake .#{{host}}

# Dry-run build to check for errors without applying
[group('deploy')]
dry-build host=shell('hostname'):
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel --dry-run

# ─── Host Shortcuts ─────────────────────────────────────────────────────────

# Deploy padrick (ThinkPad T14 AMD)
[group('host')]
padrick:
    sudo nixos-rebuild switch --flake .#padrick

# Deploy jobert (AMD+NVIDIA gaming laptop)
[group('host')]
jobert:
    sudo nixos-rebuild switch --flake .#jobert

# ─── Generation Management ─────────────────────────────────────────────────

# List system profile generations
[group('manage')]
history:
    nix profile history --profile /nix/var/nix/profiles/system

# List all generations with numbers
[group('manage')]
list-gens:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Show GC roots in the nix store
[group('manage')]
gc-root:
    ls -al /nix/var/nix/gcroots/auto/

# ─── Secrets (agenix) ──────────────────────────────────────────────────────

# Edit an encrypted secret (e.g. just secrets-edit nix-access-tokens.age)
[group('secrets')]
secrets-edit secret:
    cd {{repo_root}}/secrets && sudo agenix -i /etc/ssh/ssh_host_ed25519_key -e {{secret}}

# Decrypt a secret to stdout (e.g. just secrets-decrypt nix-access-tokens.age)
[group('secrets')]
secrets-decrypt secret:
    cd {{repo_root}}/secrets && sudo agenix -i /etc/ssh/ssh_host_ed25519_key -d {{secret}}

# Re-encrypt all secrets after key changes
[group('secrets')]
secrets-rekey:
    cd {{repo_root}}/secrets && sudo agenix -i /etc/ssh/ssh_host_ed25519_key --rekey

# ─── Secure Boot (lanzaboote/sbctl) ───────────────────────────────────────

# Back up /var/lib/sbctl before a reinstall (preserves firmware enrollment)
[group('secureboot')]
secureboot-backup dest="sbctl-backup-$(hostname).tar.gz":
    sudo tar -czpf "{{dest}}" -C /var/lib sbctl
    @echo "Saved {{dest}} — copy it off-disk before wiping."

# Restore a backup after disko mount, before nixos-install.
# Writes both /mnt/var/lib/sbctl and /mnt/persist/var/lib/sbctl.
[group('secureboot')]
secureboot-restore archive:
    sudo mkdir -p /mnt/var/lib /mnt/persist/var/lib
    sudo tar -xzpf "{{archive}}" -C /mnt/var/lib
    sudo rm -rf /mnt/persist/var/lib/sbctl
    sudo cp -a /mnt/var/lib/sbctl /mnt/persist/var/lib/
    @echo "Restored {{archive}} to /mnt/var/lib/sbctl + /mnt/persist/var/lib/sbctl"

# Check Secure Boot key + signature state
[group('secureboot')]
secureboot-status:
    sbctl status
    sudo sbctl verify

# ─── Dev Tools ──────────────────────────────────────────────────────────────

# Format with treefmt (nixfmt + shfmt)
[group('dev')]
treefmt:
    treefmt

# Run nix linter (deadnix + statix)
[group('dev')]
lint:
    deadnix .
    statix check .

# Check for unused Nix code
[group('dev')]
deadnix:
    deadnix .

# Lint Nix code for anti-patterns
[group('dev')]
statix:
    statix check .

# ─── CI (mirrors .github/workflows/ci.yml) ─────────────────────────────────

# Run the same checks as CI
[group('ci')]
ci-check:
    nix flake check --all-systems

# Run dry-builds for all hosts (same JSON enumeration as the CI matrix)
[group('ci')]
ci-dry-build:
    #!/usr/bin/env bash
    set -euo pipefail
    mapfile -t hosts < <(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[]')
    for host in "${hosts[@]}"; do
      nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" --dry-run
    done

# ─── Git ────────────────────────────────────────────────────────────────────

# Amend the last commit without changing the message
[group('git')]
amend:
    git commit --amend -a --no-edit

# Expire reflog and prune unreachable objects
[group('git')]
ggc:
    git reflog expire --expire-unreachable=now --all
    git gc --prune=now
