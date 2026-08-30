{ flakeRoot, config, ... }:

{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.nix-access-tokens = {
      file = "${flakeRoot}/secrets/nix-access-tokens.age";
      mode = "0400";
    };
  };

  system.activationScripts.agenix-tokens = ''
    # Ensure the token file exists before Nix tries to include it
    if [ ! -f "${config.age.secrets.nix-access-tokens.path}" ]; then
      mkdir -p /run/agenix
      touch "${config.age.secrets.nix-access-tokens.path}"
    fi
  '';

  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';
}
