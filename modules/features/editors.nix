{ lib, ... }:

{
  options.features.editors = {
    enable = lib.mkEnableOption "Heavy Code Editors (vscode, etc.)";
    vscode = {
      enable = lib.mkEnableOption "VS Code" // {
        default = true;
      };
    };
    zed = {
      enable = lib.mkEnableOption "Zed Editor" // {
        default = false;
      };
    };
  };
}
