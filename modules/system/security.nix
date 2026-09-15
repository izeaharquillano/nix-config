# polkit, rtkit, firewall, neovim, sudo posture.
{
  flake.modules.nixos.security = {
    security = {
      polkit.enable = true;
      rtkit.enable = true;
      sudo = {
        wheelNeedsPassword = true;
        execWheelOnly = true;
      };
    };

    networking.firewall = {
      enable = true;
      # Roaming laptops: stay quiet on untrusted LANs.
      allowPing = false;
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
