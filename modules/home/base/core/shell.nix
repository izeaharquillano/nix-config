# Simple Aspect: bash, zsh, starship, zoxide
# Dendritic module: flake.modules.homeManager.home-core-shell
{
  flake.modules.homeManager.home-core-shell =
    { pkgs, flakeRoot, ... }:

    let
      shellAliases = {
        svim = "sudoedit";
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
          enableCompletion = true;
          initExtra = ''
            bind -s '"\C-w": kill-word'
          '';
        };

        zsh = {
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

      xdg.configFile."starship.toml".source = flakeRoot + /config/starship.toml;

      home = {
        sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
          MANPAGER = "sh -c 'col -bx | bat -l man -p'";
          BAT_THEME = "gruvbox-dark";
        };

        inherit shellAliases;
      };
    };
}
