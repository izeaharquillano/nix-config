{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  enabled = lib.attrByPath [ "features" "vscode" "enable" ] false osConfig;
in
lib.mkIf enabled {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };
}
