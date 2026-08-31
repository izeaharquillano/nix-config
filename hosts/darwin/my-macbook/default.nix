{
  pkgs,
  mylib,
  ...
}:
{
  imports = mylib.scanPaths ./.;

  networking.hostName = "my-macbook";

  system.stateVersion = 5;
}
