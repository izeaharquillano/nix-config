{ lib, ... }:

{
  options.sysfeatures.vscode = {
    enable = lib.mkEnableOption "VS Code editor";
  };
}
