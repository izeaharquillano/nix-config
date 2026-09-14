# DOSBox emulator.
{
  flake.modules.nixos.vm-dosbox =
    { pkgs, ... }:

    {
      environment.systemPackages = [ pkgs.dosbox ];
    };
}
