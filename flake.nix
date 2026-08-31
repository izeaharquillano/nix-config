{
  description = "An Epic NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      agenix,
      treefmt-nix,
      ...
    }:
    let
      mylib = import ./lib { lib = nixpkgs.lib; };
      username = "ize";

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";

          programs.nixfmt.enable = true;
          programs.shfmt.enable = true;
        }
      );

      mkNixosHost =
        hostname: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              mylib
              hostname
              username
              ;
            flakeRoot = self;
          };
          modules = [
            ./hosts/nixos/${hostname}
            home-manager.nixosModules.home-manager
            inputs.agenix.nixosModules.age
            {
              mySystem.username = username;
              nixpkgs.overlays = [ (import ./overlays) ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-bak";
                users.${username} = import ./home/hosts/nixos/${hostname};
                extraSpecialArgs = {
                  inherit
                    inputs
                    mylib
                    hostname
                    username
                    ;
                  flakeRoot = self;
                };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations.padrick = mkNixosHost "padrick" "x86_64-linux";
      nixosConfigurations.jobert = mkNixosHost "jobert" "x86_64-linux";

      # Placeholder for future macOS/darwin hosts.
      # Uncomment and configure when adding a darwin host.
      # darwinConfigurations.my-macbook = inputs.nix-darwin.lib.darwinSystem {
      #   system = "aarch64-darwin";
      #   modules = [ ./hosts/darwin/my-macbook ];
      # };
      darwinConfigurations = { };

      checks = forAllSystems (
        system:
        {
          formatting = treefmtEval.${system}.config.build.check self;
        }
        // nixpkgs.lib.mapAttrs' (name: cfg: {
          name = "${name}-eval";
          value = nixpkgs.legacyPackages.${system}.runCommand "check-${name}-eval" { } ''
            [ -n "${cfg.config.networking.hostName}" ] && \
            [ -n "${cfg.config.mySystem.username}" ] && \
            [ -n "${cfg.config.system.stateVersion}" ] && \
            echo "ok" > $out
          '';
        }) self.nixosConfigurations
      );

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      apps = forAllSystems (system: {
        agenix = {
          type = "app";
          program = "${agenix.packages.${system}.default}/bin/agenix";
          meta.description = "Secret management with age";
        };
      });

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inputsFrom = [ treefmtEval.${system}.config.build.devShell ];
          packages = [ agenix.packages.${system}.default ];
        };
      });

      overlays.default = import ./overlays;

      nixosModules = {
        default = {
          imports = [
            ./modules/nixos
          ];

          config = {
            nixpkgs.overlays = [ (import ./overlays) ];

            mySystem.username = nixpkgs.lib.mkDefault "ize";
            mySystem.kernelPackage = nixpkgs.lib.mkDefault nixpkgs.linuxPackages_7_2;
          };
        };
      };

      # Placeholder for future darwin modules.
      # darwinModules = {
      #   default = {
      #     imports = [ ./modules/darwin ];
      #     config = { nixpkgs.overlays = [ (import ./overlays) ]; };
      #   };
      # };

      packages = forAllSystems (system: {
        gruvbox-material-yazi =
          nixpkgs.legacyPackages.${system}.callPackage ./pkgs/gruvbox-material-yazi.nix
            { };
      });
    };
}
