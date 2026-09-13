# Simple Aspect: OpenSSH, key-only, no root login
# Dendritic module: flake.modules.nixos.base-ssh
{
  flake.modules.nixos.base-ssh =
    { pkgs, ... }:

    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };
    };
}
