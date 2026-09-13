# Simple Aspect: VS Code with extensions.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.homeManager.home-features-vscode
{
  flake.modules.homeManager.home-features-vscode =
    { pkgs, flakeRoot, ... }:

    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
          jdinhlife.gruvbox
          jnoortheen.nix-ide
          ms-dotnettools.csharp
        ];
      };
      xdg.configFile."Code/User/settings.json".source = flakeRoot + /config/vscode/settings.json;
      xdg.configFile."vscode/.vimrc".source = flakeRoot + /config/vscode/.vimrc;
    };
}
