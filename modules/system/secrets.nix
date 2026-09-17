# agenix identity + nix-access-tokens.
{ inputs, ... }:
{
  flake.modules.nixos.secrets =
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
        # Persistent path first: on impermanence hosts `/etc/ssh` is a
        # bind-mount missing at boot decrypt time (agenix#45); `/persist`
        # is always ready. Second entry covers non-impermanence/installs.
        identityPaths = [
          "/persist/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key"
        ];

        # 0440 root:wheel so user + daemon both read `!include` (https://wiki.nixos.org/wiki/Agenix).
        secrets.nix-access-tokens = {
          file = flakeRoot + /secrets/nix-access-tokens.age;
          owner = "root";
          group = "wheel";
          mode = "0440";
        };
      };

      nix.extraOptions = ''
        !include ${config.age.secrets.nix-access-tokens.path}
      '';

      # Empty placeholder if undecryptable so `!include` never breaks nix.
      # Skipped when `agenixInstall` itself aborts (fresh host) — rekey
      # via the two-pass workflow in the README. (Internal script name;
      # re-check on `nix flake update agenix`.)
      system.activationScripts.nixAccessTokensFallback = lib.stringAfter [ "agenixInstall" ] ''
        tokenPath="${config.age.secrets.nix-access-tokens.path}"
        if [ ! -s "$tokenPath" ]; then
          echo "agenix: $tokenPath missing or empty (fresh host without host key?) — writing empty placeholder; expect GitHub rate limits until rekeyed" >&2
          mkdir -p "$(dirname "$tokenPath")"
          install -m 0440 -o root -g wheel /dev/null "$tokenPath" || true
        fi
      '';
    };
}
