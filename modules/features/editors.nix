{ lib, ... }:

{
  options.features.editors = {
    enable = lib.mkEnableOption "Heavy Code Editors (vscode, etc.)";
  };
}
