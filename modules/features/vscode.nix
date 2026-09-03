{ lib, ... }:

{
  options.features.vscode = {
    enable = lib.mkEnableOption "VS Code editor";
  };
}
