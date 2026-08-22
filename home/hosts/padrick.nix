{ pkgs, inputs, ... }:

{
  imports = [
    ../../home/core
    ../../home/desktop
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
  ];
}
