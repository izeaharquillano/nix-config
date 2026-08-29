{ pkgs, ... }:

{
  programs.git.settings = {
    userName = "Izeah Arquillano";
    userEmail = "izeaharquillano@gmail.com";
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
        ls = "eza --icons=always --color=always --group-directories-first";
        ll = "eza -alF --icons=always --color=always --group-directories-first";
        lll = "eza -al --icons=always --group-directories-first --git --color-scale=all --color-scale-mode=gradient";
        lt = "eza --tree --level=2 --icons=always --color=always";
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
