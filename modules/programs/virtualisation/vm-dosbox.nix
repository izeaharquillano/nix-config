# DOSBox emulator (per-user; HM-only feature).
{
  flake.modules.homeManager.vm-dosbox =
    { pkgs, ... }:

    {
      home.packages = [ pkgs.dosbox ];
    };
}
