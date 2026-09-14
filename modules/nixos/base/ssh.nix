# OpenSSH, key-only, no root login.
{
  flake.modules.nixos.base-ssh = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
