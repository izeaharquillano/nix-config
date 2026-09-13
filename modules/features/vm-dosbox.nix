# Simple Aspect: DOSBox emulator.
# Import this module = enabled (pure dendritic: composition decides).
# Dendritic module: flake.modules.nixos.vm-dosbox
{
  flake.modules.nixos.vm-dosbox =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [ dosbox ];
    };
}
