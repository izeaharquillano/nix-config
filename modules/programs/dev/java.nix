{
  flake.modules.nixos.java =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.jdk25
      ];
    };
}
