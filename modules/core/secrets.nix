{ flakeRoot, config, ... }:

{
  age = {
    secrets.nix-access-tokens = {
      file = "${flakeRoot}/secrets/nix-access-tokens.age";
      mode = "0444";
    };
  };

  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';
}
