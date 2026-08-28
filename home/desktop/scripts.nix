{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "output-scale" (builtins.readFile ../../scripts/output-scale))
  ];
}
