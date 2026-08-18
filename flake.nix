{
  description = "NixOS Epic Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable";

    home-manager = {
      # url = "github:nix-community/home-manager/release-26.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";
    hyprland.url = "github:hyprwm/Hyprland";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, niri, hyprland, zen-browser, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        niri.nixosModules.niri
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.ize = import ./home.nix;
            extraSpecialArgs = { inherit inputs; };
          };
        }
      ];
    };
  };
}
