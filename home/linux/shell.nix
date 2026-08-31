{ pkgs, ... }:

let
  sharedAliases = {
    svim = "sudoedit";
    cat = "bat";
  };

  nixosAliases = {
    bldswc = "sudo nixos-rebuild switch";
    bldflk = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
    nixgarb = "sudo nix-collect-garbage";
    sagenix = "sudo agenix -i /etc/ssh/ssh_host_ed25519_key";
  };

  zshAliases =
    sharedAliases
    // nixosAliases
    // {
      ls = "eza --icons=always --color=always --group-directories-first";
      ll = "eza -alF --icons=always --color=always --group-directories-first";
      lll = "eza -al --icons=always --group-directories-first --git --color-scale=all --color-scale-mode=gradient";
      lt = "eza --tree --level=2 --icons=always --color=always";
    };
in
{
  programs = {
    bash = {
      enable = true;
      shellAliases = sharedAliases // nixosAliases;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = zshAliases;
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
