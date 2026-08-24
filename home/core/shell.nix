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
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        svim = "sudoedit";
        bldswc = "sudo nixos-rebuild switch";
        bldflk = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
        nixgarb = "sudo nix-collect-garbage";
      };
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
