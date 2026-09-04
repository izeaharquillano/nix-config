{ pkgs, ... }:

let
  shellAliases = {
    svim = "sudoedit";
    cat = "bat";
    bldswc = "sudo nixos-rebuild switch";
    bldflk = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
    nixgc = "sudo nix-collect-garbage --delete-older-than 14d";
    sagenix = "sudo agenix -i /etc/ssh/ssh_host_ed25519_key";
    ls = "eza --icons=always --color=always --group-directories-first";
    ll = "eza -alF --icons=always --color=always --group-directories-first";
    lll = "eza -al --icons=always --group-directories-first --git --color-scale=all --color-scale-mode=gradient";
    lt = "eza --tree --level=2 --icons=always --color=always";
  };
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      bind -s '"\C-w": kill-word'
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[[3~" delete-char
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".source = ../../../config/starship.toml;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    BAT_THEME = "gruvbox-dark";
  };

  home.shellAliases = shellAliases;
}
