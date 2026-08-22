{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
  gtk.cursorTheme = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
  };

  programs = {
    bash = {
      enable = true;
      shellAliases = {
        svim = "sudoedit";
        bldswc = "sudo nixos-rebuild switch";
        bldflk = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
        nixgarb = "sudo nix-collect-garbage";
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
