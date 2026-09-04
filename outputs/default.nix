{
  self,
  nixpkgs,
  home-manager,
  agenix,
  treefmt-nix,
  pre-commit-hooks,
  ...
}@inputs:
let
  lib = nixpkgs.lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars { inherit lib; };
  username = myvars.username;

  forAllSystems = lib.genAttrs [
    "x86_64-linux"
  ];

  treefmtEval = forAllSystems (
    system:
    treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
      projectRootFile = "flake.nix";

      programs.nixfmt.enable = true;
      programs.shfmt.enable = true;
    }
  );

  preCommitEval = forAllSystems (
    system:
    pre-commit-hooks.lib.${system}.run {
      src = self;
      hooks = {
        nixfmt.enable = true;
      };
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
          myvars
          hostname
          username
          ;
        flakeRoot = self;
      };
      modules = [
        ../hosts/nixos/${hostname}
        home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.age
        {
          mySystem.username = username;
          nixpkgs.overlays = [ (import ../overlays) ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bak";
            overwriteBackup = true;
            users.${username} = import ../home/hosts/nixos/${hostname};
            extraSpecialArgs = {
              inherit
                inputs
                mylib
                myvars
                hostname
                username
                ;
              flakeRoot = self;
            };
          };
        }
      ];
    };

  # Server host: no home-manager, no desktop environment
  mkNixosServerHost =
    hostname: system:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          mylib
          myvars
          hostname
          username
          ;
        flakeRoot = self;
      };
      modules = [
        ../hosts/nixos/${hostname}
        inputs.agenix.nixosModules.age
        {
          mySystem.username = username;
          nixpkgs.overlays = [ (import ../overlays) ];
        }
      ];
    };

in
{
  nixosConfigurations.padrick = mkNixosHost "padrick" "x86_64-linux";
  nixosConfigurations.jobert = mkNixosHost "jobert" "x86_64-linux";
  nixosConfigurations.server-example = mkNixosServerHost "server-example" "x86_64-linux";

  checks = forAllSystems (
    system:
    {
      formatting = treefmtEval.${system}.config.build.check self;
      pre-commit = preCommitEval.${system};
    }
    // lib.mapAttrs' (name: cfg: {
      name = "${name}-eval";
      value = nixpkgs.legacyPackages.${system}.runCommand "check-${name}-eval" { } ''
        [ -n "${cfg.config.networking.hostName}" ] && \
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

  devShells = forAllSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      default = pkgs.mkShell {
        inputsFrom = [
          treefmtEval.${system}.config.build.devShell
        ];
        packages = [
          agenix.packages.${system}.default
          pkgs.nixfmt
          pkgs.deadnix
          pkgs.statix
        ];
      };
    }
  );

  overlays.default = import ../overlays;

  nixosModules = {
    default = {
      imports = [
        ../modules/nixos
      ];

      config = {
        nixpkgs.overlays = [ (import ../overlays) ];

        mySystem.username = lib.mkDefault myvars.username;
        mySystem.kernelPackage = lib.mkDefault nixpkgs.linuxPackages_latest;
      };
    };
  };

  packages = forAllSystems (system: {
    gruvbox-material-yazi =
      nixpkgs.legacyPackages.${system}.callPackage ../pkgs/gruvbox-material-yazi.nix
        { };
  });
}
