# CLI tools + yazi + tmux (`eza`/`zoxide` come from shell).
{
  flake.modules.homeManager.cli =
    { pkgs, flakeRoot, ... }:

    {
      home.packages = [
        pkgs.fd
        pkgs.jq
        pkgs.fzf
        pkgs.curl
        pkgs.unzip
        pkgs.bat
        pkgs.ripgrep
        pkgs.tealdeer
        pkgs.fastfetch
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
