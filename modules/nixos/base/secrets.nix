# Simple Aspect: agenix identity + nix-access-tokens
# Dendritic module: flake.modules.nixos.base-secrets
# Imports agenix directly so `nixosModules.default` keeps `age.secrets`.
{ inputs, ... }:
{
  flake.modules.nixos.base-secrets =
    {
      config,
      lib,
      username,
      flakeRoot,
      ...
    }:

    {
      imports = [
        inputs.agenix.nixosModules.age
      ];

      age = {
        identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

        # Owner-readable (0400); root reads via DAC, 0644 would leak the token.
        # See https://wiki.nixos.org/wiki/Agenix
        secrets.nix-access-tokens = {
          file = "${flakeRoot}/secrets/nix-access-tokens.age";
          owner = username;
          group = "users";
          mode = "0400";
        };
      };

      nix.extraOptions = ''
        !include ${config.age.secrets.nix-access-tokens.path}
      '';

      # Empty placeholder if undecryptable; `!include` must never break nix.
      system.activationScripts.nixAccessTokensFallback = lib.stringAfter [ "agenixInstall" ] ''
        tokenPath="${config.age.secrets.nix-access-tokens.path}"
        if [ ! -e "$tokenPath" ]; then
          mkdir -p "$(dirname "$tokenPath")"
          : > "$tokenPath"
          chown ${username}:users "$tokenPath" || true
          chmod 0400 "$tokenPath" || true
        fi
      '';
    };
}
