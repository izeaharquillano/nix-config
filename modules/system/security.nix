# polkit, rtkit, firewall, neovim.
{
  flake.modules.nixos.security = {
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
