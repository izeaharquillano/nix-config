{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    jq
    fzf
    eza
    curl
    unzip
    bat
    ripgrep
    tealdeer
    fastfetch
    zoxide
  ];

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
    flavors = {
      gruvbox-material = pkgs.gruvbox-material-yazi;
    };
    theme.flavor = {
      dark = "gruvbox-material";
      light = "gruvbox-material";
    };
  };

  xdg.configFile."tmux/tmux.conf".source = ../../config/tmux/tmux.conf;
}
