# Simple Aspect: CLI tools + yazi + tmux
# Dendritic module: flake.modules.homeManager.home-core-cli
{
  flake.modules.homeManager.home-core-cli =
    { pkgs, flakeRoot, ... }:

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

      xdg.configFile."tmux/tmux.conf".source = flakeRoot + /config/tmux/tmux.conf;
    };
}
