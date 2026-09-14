{ inputs, ... }:
{
  flake.nixosConfigurations.padrick = inputs.self.lib.mkNixosHost "padrick" "x86_64-linux";
}
