# Simple Aspect: agenix identity + nix-access-tokens
# Dendritic module: flake.modules.nixos.base-secrets
# Imports agenix directly so `nixosModules.default` keeps `age.secrets`.
{ inputs, ... }:
{
  flake.modules.nixos.base-secrets =
    {
      config,
      lib,
      flakeRoot,
      ...
    }:

    {
      imports = [
        inputs.agenix.nixosModules.age
      ];

      age = {
        identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

        # Group-readable (0440 root:wheel): the Nix *client* parses `!include`
        # below as the invoking uid, while the daemon runs as root. 0400
        # root-only would break user invocations; 0644 would leak the token
        # to every local process. User `ize` is in `wheel`, so both read.
        # See https://wiki.nixos.org/wiki/Agenix
        secrets.nix-access-tokens = {
          file = "${flakeRoot}/secrets/nix-access-tokens.age";
          owner = "root";
          group = "wheel";
          mode = "0440";
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
          chown root:wheel "$tokenPath" || true
          chmod 0440 "$tokenPath" || true
        fi
      '';
    };
}
