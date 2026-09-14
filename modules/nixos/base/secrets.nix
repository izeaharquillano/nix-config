# Simple Aspect: agenix identity + nix-access-tokens
# Dendritic module: flake.modules.nixos.base-secrets
# Explicitly imports agenix here (not via factory magic) so the module is
# self-contained and `nixosModules.default` consumers get `age.secrets`.
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

        # Owner is the primary user (not root) with mode 0400.
        # Root (nix-daemon) bypasses DAC so it can always read; the user can
        # read as owner. 0644 is NOT needed and would leak the GitHub token
        # to every local user. See https://wiki.nixos.org/wiki/Agenix
        # (`owner = "myuser"; group = "users"; mode = "600";` pattern).
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

      # `!include` fails hard when the target is missing, which deadlocks a
      # fresh host that cannot decrypt yet (every nix command errors, including
      # the rebuild that would deploy the rekeyed secret). Touch an empty
      # placeholder after agenix runs so nix keeps working with no tokens
      # until the real secret decrypts.
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
