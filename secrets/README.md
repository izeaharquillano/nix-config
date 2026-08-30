# Secrets Management

This directory contains encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix).

## Structure

```
secrets/
├── system/              # Shared secrets (accessible by all hosts)
│   └── secrets.yaml     # restic-password, netbird-setup-key
├── hosts/
│   ├── padrick/         # Padrick-specific secrets
│   └── jobert/          # Jobert-specific secrets
└── README.md
```

## Initial Setup

### 1. Get SSH Host Keys

Each host needs its SSH host public key for age decryption:

```bash
# On each host:
cat /etc/ssh/ssh_host_ed25519_key.pub
```

### 2. Convert SSH Keys to Age

```bash
nix-shell -p ssh-to-age --run '
echo "ssh-ed25519 AAAA... root@padrick" | ssh-to-age
echo "ssh-ed25519 AAAA... root@jobert" | ssh-to-age
'
```

### 3. Create Encrypted Secrets

```bash
nix-shell -p sops ssh-to-age --run '
AGE_KEY_PADRICK=$(echo "ssh-ed25519 AAAA... root@padrick" | ssh-to-age)
AGE_KEY_JOBERT=$(echo "ssh-ed25519 AAAA... root@jobert" | ssh-to-age)

cat > /tmp/secrets.yaml << EOF
netbird-setup-key: your-netbird-setup-key
restic-password: your-restic-password
EOF

sops encrypt --config /dev/null --age "$AGE_KEY_PADRICK,$AGE_KEY_JOBERT" /tmp/secrets.yaml > secrets/system/secrets.yaml
'
```

### 4. Deploy

```bash
sudo nixos-rebuild switch --flake .#padrick
```

## Adding a New Host

1. Get the new host's SSH public key:
   ```bash
   ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. Convert to age key:
   ```bash
   echo "ssh-ed25519 AAAA... root@newhost" | ssh-to-age
   ```

3. Decrypt the existing secrets, then re-encrypt with all recipients:
   ```bash
   nix-shell -p sops ssh-to-age --run '
   AGE_KEY_PADRICK=$(echo "ssh-ed25519 AAAA... root@padrick" | ssh-to-age)
   AGE_KEY_JOBERT=$(echo "ssh-ed25519 AAAA... root@jobert" | ssh-to-age)
   AGE_KEY_NEWHOST=$(echo "ssh-ed25519 AAAA... root@newhost" | ssh-to-age)
   
   sudo SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key sops -d secrets/system/secrets.yaml > /tmp/secrets.yaml
   
   sops encrypt --config /dev/null --age "$AGE_KEY_PADRICK,$AGE_KEY_JOBERT,$AGE_KEY_NEWHOST" /tmp/secrets.yaml > secrets/system/secrets.yaml
   '
   ```

4. Deploy to the new host.

## Editing Secrets

```bash
# Edit encrypted secrets
sops secrets/system/secrets.yaml

# View decrypted secrets (requires root for SSH host key access)
sudo SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key sops -d secrets/system/secrets.yaml
```

## How It Works

1. Secrets are encrypted using [age](https://github.com/FiloSottile/age) with SSH public keys
2. Each secret in NixOS modules specifies `sopsFile` with an absolute path to the encrypted file
3. At boot/activation, `sops-install-secrets` decrypts secrets to `/run/secrets/`
4. NixOS services reference secrets via `config.sops.secrets.<name>.path`
5. Secrets are never stored in plaintext in the Nix store

## Troubleshooting

### Secrets not decrypting

- Check that the host's SSH private key exists at `/etc/ssh/ssh_host_ed25519_key`
- Verify the age recipient fingerprints match: `echo "ssh-ed25519 AAAA..." | ssh-to-age`
- Check sops-nix logs: `journalctl -u sops-nix`

### Permission denied

- Ensure the `owner` and `group` settings in the feature module's `sops.secrets` definition are correct
- Check file permissions: `ls -la /run/secrets/`
