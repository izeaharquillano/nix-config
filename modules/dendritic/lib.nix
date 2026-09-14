# Constants Aspect + Factory Aspect + DRY Aspect.
#
# - `flake.lib.vars`: single source of truth for user identity.
# - `flake.lib.mkNixosHost / mkNixosServerHost / mkDarwinHost`: factories that
#   instantiate hosts from dendritic modules. They inject the same
#   `specialArgs`/`extraSpecialArgs` everywhere, so all system and home
#   modules keep working unchanged:
#     hostname, flakeRoot, inputs, myvars, username
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

  inherit (vars) username;

  specialArgsFor = hostname: {
    inherit
      inputs
      hostname
      username
      mylib
      ;
    myvars = vars;
    flakeRoot = self;
  };

  # Backwards-compat shim: `mylib` used to carry `scanPaths`/`relativeToRoot`.
  # `import-tree` auto-imports everything under `modules/`, so no aggregator
  # is needed. Kept as an empty set so external consumers referencing
  # `flake.lib.mylib` don't break; do not add helpers here.
  mylib = { };

  baseSystemModules = [
    {
      nixpkgs.overlays = [
        self.overlays.default
        inputs.nix-alien.overlays.default
      ];
    }
  ];

  # Only binds `users.<name>` + `extraSpecialArgs`. Common HM settings
  # (`useGlobalPkgs`, `backupFileExtension`, ...) live in the dendritic
  # `home-manager` modules (`modules/tools/home-manager.nix`) which the
  # `desktop` system type already imports — do not duplicate them here and
  # do not re-import the home-manager NixOS/Darwin module here.
  homeManagerUsersBlock = hostname: {
    home-manager = {
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
          # NOTE: home-manager integration + agenix come from the composition
          # itself (`nixos.desktop` imports `home-manager`, `base-secrets`
          # imports agenix). The factory only binds the per-host HM user.
          (homeManagerUsersBlock hostname)
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
          # NOTE: agenix comes from `base-secrets` via the `server` type.
        ]
        ++ baseSystemModules;
      };

    mkDarwinHost =
      hostname: system:
      let
        agenixDarwin =
          if inputs.agenix ? darwinModules then
            inputs.agenix.darwinModules.age
          else
            inputs.agenix.nixosModules.age;
      in
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = specialArgsFor hostname;
        modules = [
          self.modules.darwin.${hostname}
          agenixDarwin
          inputs.home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager = {
              users.${username} = self.modules.homeManager.${hostname};
              extraSpecialArgs = specialArgsFor hostname;
            };
          }
        ];
      };
  };
}
