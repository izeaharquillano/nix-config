{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = osConfig.features.editors or { enable = false; };
in
lib.mkIf cfg.enable (
  lib.mkMerge [
    {
      programs.vscode = lib.mkIf (cfg.vscode.enable or false) {
        enable = true;
        package = pkgs.vscode;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
          jdinhlife.gruvbox
          jnoortheen.nix-ide
        ];
      };
    }
    (lib.mkIf (cfg.vscode.enable or false) {
      xdg.configFile."Code/User/settings.json".source = ../../../config/vscode/settings.json;
      xdg.configFile."vscode/.vimrc".source = ../../../config/vscode/.vimrc;
    })
    {
      programs.zed-editor = lib.mkIf (cfg.zed.enable or false) {
        enable = true;
      };
    }
  ]
)
