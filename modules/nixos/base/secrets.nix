# Simple Aspect: agenix identity + nix-access-tokens
# Dendritic module: flake.modules.nixos.base-secrets
{
  flake.modules.nixos.base-secrets =
    { flakeRoot, config, ... }:

    {
      age = {
        identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

        secrets.nix-access-tokens = {
          file = "${flakeRoot}/secrets/nix-access-tokens.age";
          mode = "0644";
        };
      };

      nix.extraOptions = ''
        !include ${config.age.secrets.nix-access-tokens.path}
      '';
    };
}
