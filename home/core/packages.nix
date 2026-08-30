{ pkgs, ... }:

{
  programs.npm.enable = true;

  home.packages = with pkgs; [
    # utils
    fd
    jq
    fzf
    gcc
    eza
    curl
    unzip
    starship
    tealdeer
    xdg-user-dirs
    bat

    # terminal tools
    fastfetch
    zoxide
    lazygit
    ripgrep
    opencode
  ];
}
