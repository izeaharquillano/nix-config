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
    starship
    tealdeer
    xdg-user-dirs

    # terminal tools
    btop
    fastfetch
    zoxide
    lazygit
    ripgrep
    opencode

    # gui apps
    discord-ptb
  ];
}
