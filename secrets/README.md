# Secrets Management

This directory contains encrypted secrets managed by [agenix](https://github.com/ryantm/agenix).

## Structure

```
secrets/
├── secrets.nix              # Public key declarations for each secret
├── nix-access-tokens.age    # Nix/GitHub access tokens (encrypted)
├── netbird-setup-key.age    # NetBird VPN setup key (encrypted)
├── restic-password.age      # Restic repository password (encrypted)
└── README.md
```

## Initial Setup

### 1. Get SSH Host Public Keys

Each host needs its SSH host public key for age encryption:

```bash
# On each host:
ssh-keyscan <hostname> 2>/dev/null | grep ssh-ed25519
```

### 2. Create `secrets/secrets.nix`

This file declares which public keys can decrypt each secret:

```nix
let
  padrick = "ssh-ed25519 AAAA... root@padrick";
  jobert = "ssh-ed25519 AAAA... root@jobert";
  systems = [ padrick jobert ];
in
{
  "nix-access-tokens.age".publicKeys = systems;
  "netbird-setup-key.age".publicKeys = systems;
  "restic-password.age".publicKeys = systems;
}
```

### 3. Create Encrypted Secrets

```bash
# Install agenix CLI (or use nix run)
nix profile install github:ryantm/agenix

# Create/edit each secret
agenix -e nix-access-tokens.age
agenix -e netbird-setup-key.age
agenix -e restic-password.age
```

Each command opens your `$EDITOR` with a temp file. Save and quit to encrypt.

### 4. Deploy

```bash
sudo nixos-rebuild switch --flake .#padrick
```

## Adding a New Host

1. Get the new host's SSH public key:
   ```bash
   ssh-keyscan <new-host> 2>/dev/null | grep ssh-ed25519
   ```

2. Add the key to `secrets/secrets.nix` for each secret it should decrypt

3. Re-encrypt all secrets:
   ```bash
   agenix --rekey
   ```

4. Deploy to the new host

## Editing Secrets

```bash
# Edit an encrypted secret (opens in $EDITOR)
agenix -e <secret-name>.age

# Decrypt a secret to stdout (for debugging)
agenix -d <secret-name>.age
```

## How It Works

1. Secrets are encrypted using [age](https://github.com/FiloSottile/age) with SSH public keys
2. Each `.age` file is listed in a NixOS module via `age.secrets.<name>.file`
3. At boot/activation, agenix decrypts secrets to `/run/agenix/<name>`
4. NixOS services reference secrets via `config.age.secrets.<name>.path`
5. Secrets are never stored in plaintext in the Nix store

## Troubleshooting

### Secrets not decrypting

- Check that the host's SSH private key exists at `/etc/ssh/ssh_host_ed25519_key`
- Verify the host's public key is listed in `secrets/secrets.nix`
- Check agenix logs: `journalctl -u agenix`

### Permission denied

- Ensure the `owner` and `group` settings in the secret's definition are correct
- Check file permissions: `ls -la /run/agenix/`
