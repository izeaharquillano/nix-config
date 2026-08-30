{ flakeRoot, config, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops/age/keys.txt";

    secrets.nix-access-tokens = {
      sopsFile = "${flakeRoot}/secrets/system/secrets.yaml";
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };

  nix.extraOptions = ''
    !include ${config.sops.secrets.nix-access-tokens.path}
  '';
}
