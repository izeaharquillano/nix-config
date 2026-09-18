# VS Code + extensions.
{
  flake.modules.homeManager.vscode =
    { pkgs, flakeRoot, ... }:

    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode;
        profiles.default.extensions = [
          pkgs.vscode-extensions.vscodevim.vim
          pkgs.vscode-extensions.jdinhlife.gruvbox
          pkgs.vscode-extensions.jnoortheen.nix-ide
        ];
      };
      xdg.configFile."Code/User/settings.json".source = flakeRoot + /config/vscode/settings.json;
      xdg.configFile."vscode/.vimrc".source = flakeRoot + /config/vscode/.vimrc;
    };
}
