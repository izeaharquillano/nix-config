# Constants Aspect + Factory Aspect + DRY Aspect.
#
# - `flake.lib.vars`: single source of truth for user identity (was `vars/`).
# - `flake.lib.mylib`: custom helpers (was `lib/`). `scanPaths` is kept for
#   external compatibility; inside this repo `import-tree` auto-imports
#   everything under `modules/`, so no aggregator files are needed.
# - `flake.lib.mkNixosHost / mkNixosServerHost / mkDarwinHost`: factories that
#   instantiate hosts from dendritic modules (were `outputs/default.nix`).
#   They inject the same `specialArgs`/`extraSpecialArgs` as before, so all
#   system and home modules keep working unchanged:
#     hostname, flakeRoot, inputs, mylib, myvars, username
{
  inputs,
  self,
  lib,
  ...
}:
let
  vars = {
    username = "ize";
    userfullname = "Izeah Arquillano";
    useremail = "izeaharquillano@gmail.com";
  };

  mylib = {
    scanPaths =
      dir:
      builtins.map (f: (dir + "/${f}")) (
        builtins.attrNames (
          lib.attrsets.filterAttrs (
            name: _type:
            (_type == "directory") || ((name != "default.nix") && (lib.strings.hasSuffix ".nix" name))
          ) (builtins.readDir dir)
        )
      );

    # Convert a repo-relative path to an absolute path.
    relativeToRoot = path: (builtins.toString ../.) + "/../../${path}";

    # specialArgs passed to all NixOS, Darwin, and Home Manager modules.
    # All modules can expect these arguments:
    #
    #   hostname  - string  - Current host name (e.g. "padrick")
    #   flakeRoot - path    - Flake root (self) for referencing repo files
    #   inputs    - attrset - Flake inputs (nixpkgs, home-manager, etc.)
    #   mylib     - attrset - Custom library functions (scanPaths, relativeToRoot)
    #   myvars    - attrset - User identity vars (username, userfullname, useremail)
    #   username  - string  - Primary user username (e.g. "ize")
  };

  username = vars.username;

  specialArgsFor = hostname: {
    inherit inputs hostname username;
    mylib = mylib;
    myvars = vars;
    flakeRoot = self;
  };

  baseSystemModules = [
    {
      mySystem.username = username;
      nixpkgs.overlays = [
        self.overlays.default
        inputs.nix-alien.overlays.default
      ];
    }
  ];

  homeManagerBlock = hostname: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      overwriteBackup = true;
      users.${username} = self.modules.homeManager.${hostname};
      extraSpecialArgs = specialArgsFor hostname;
    };
  };
in
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib = {
    inherit mylib vars;
    myvars = vars;

    mkNixosHost =
      hostname: system:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgsFor hostname;
        modules = [
          self.modules.nixos.${hostname}
          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.age
          (homeManagerBlock hostname)
        ]
        ++ baseSystemModules;
      };

    mkNixosServerHost =
      hostname: system:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgsFor hostname;
        modules = [
          self.modules.nixos.${hostname}
          inputs.agenix.nixosModules.age
        ]
        ++ baseSystemModules;
      };

    mkDarwinHost =
      hostname: system:
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = specialArgsFor hostname;
        modules = [
          self.modules.darwin.${hostname}
          inputs.home-manager.darwinModules.home-manager
          inputs.agenix.nixosModules.age
          {
            mySystem.username = username;
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak";
              users.${username} = self.modules.homeManager.${hostname};
              extraSpecialArgs = specialArgsFor hostname;
            };
          }
        ];
      };
  };
}
