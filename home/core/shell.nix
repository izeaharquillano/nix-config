{ pkgs, ... }:

{
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
