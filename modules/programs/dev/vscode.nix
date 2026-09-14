# VS Code + extensions.
{
  flake.modules.homeManager.vscode =
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
