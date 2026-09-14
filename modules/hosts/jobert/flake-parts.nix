{ inputs, ... }:
{
  flake.nixosConfigurations.jobert = inputs.self.lib.mkNixosHost "jobert" "x86_64-linux";
}
