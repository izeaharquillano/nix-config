{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  enabled = lib.attrByPath [ "sysfeatures" "vscode" "enable" ] false osConfig;
in
lib.mkIf enabled {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };
}
