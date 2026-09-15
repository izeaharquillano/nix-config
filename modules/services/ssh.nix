# OpenSSH, key-only, primary user only, no fail2ban by design.
{
  flake.modules.nixos.ssh =
    { username, ... }:
    {
      services.openssh = {
        enable = true;
        # Closed everywhere (roaming laptops). The secrets two-pass flow needs
        # LAN `ssh-keyscan`: temporarily allow TCP/22 on the new host for it.
        openFirewall = false;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          PermitEmptyPasswords = false;
          AllowUsers = [ username ];
          MaxAuthTries = 3;
          LoginGraceTime = "30s";
          X11Forwarding = false;
        };
      };
    };
}
