{ pkgs, ... }:

{
  programs.npm.enable = true;

  home.packages = with pkgs; [
    # utils
    fd
    fzf
    gcc
    curl
    unzip
    tealdeer

    # terminal tools
    btop
    fastfetch
    zoxide
    lazygit
    ripgrep
    opencode
  ];
}
