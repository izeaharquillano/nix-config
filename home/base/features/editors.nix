{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  enabled = lib.attrByPath [ "features" "editors" "enable" ] false osConfig;
in
lib.mkIf enabled {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jdinhlife.gruvbox
      jnoortheen.nix-ide
    ];
  };
  xdg.configFile."Code/User/settings.json".source = ../../../config/vscode/settings.json;

  xdg.configFile."vscode/.vimrc".source = ../../../config/vscode/.vimrc;
}
