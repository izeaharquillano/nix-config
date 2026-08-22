{ ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./nix.nix
    ./packages.nix
    ./users.nix
  ];
}
