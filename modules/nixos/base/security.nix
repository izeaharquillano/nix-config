# Simple Aspect: polkit, rtkit, firewall, neovim
# Dendritic module: flake.modules.nixos.base-security
{
  flake.modules.nixos.base-security =
    { pkgs, ... }:

    {
      security = {
        polkit.enable = true;
        rtkit.enable = true;
      };

      networking.firewall = {
        enable = true;
        allowPing = true;
      };

      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };
    };
}
