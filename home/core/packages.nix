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

    # terminal tools
    btop-cuda
    fastfetch
    zoxide
    lazygit
    ripgrep
    opencode
  ];
}
