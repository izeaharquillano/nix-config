{
  description = "An Epic NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    niri.url = "github:sodiboo/niri-flake";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    mylib = import ./lib { lib = nixpkgs.lib; };
  in
  {
    nixosConfigurations.padrick = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs mylib; hostname = "padrick"; };
      modules = [
        ./hosts/padrick
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.ize = import ./home/hosts/padrick;
            extraSpecialArgs = { inherit inputs mylib; hostname = "padrick"; };
          };
        }
      ];
    };

    nixosConfigurations.jobert = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs mylib; hostname = "jobert"; };
      modules = [
        ./hosts/jobert
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.ize = import ./home/hosts/jobert;
            extraSpecialArgs = { inherit inputs mylib; hostname = "jobert"; };
          };
        }
      ];
    };
  };
}
