{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utils
    fd
    fzf
    gcc
    curl
    unzip

    # terminal tools
    btop
    fastfetch
    zoxide
    lazygit
    ripgrep
    opencode
  ];
}
