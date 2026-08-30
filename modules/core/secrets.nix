{ flakeRoot, config, ... }:

{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.nix-access-tokens = {
      file = "${flakeRoot}/secrets/nix-access-tokens.age";
      mode = "0400";
    };
  };

  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';
}
