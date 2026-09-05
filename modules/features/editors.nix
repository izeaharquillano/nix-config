{ lib, ... }:

let
  mkEnabledOption = desc: lib.mkEnableOption desc // { default = true; };
in
{
  options.features.editors = {
    enable = lib.mkEnableOption "Heavy Code Editors (vscode, etc.)";
    vscode.enable = mkEnabledOption "VS Code";
    zed.enable = lib.mkEnableOption "Zed Editor";
  };
}
