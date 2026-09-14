# User identity + host factories (`mkNixosHost`/`mkNixosServerHost`/`mkDarwinHost`).
# Factories inject shared `specialArgs` (hostname, flakeRoot, inputs, myvars, username).
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

  # Empty legacy `mylib` shim for external compat; add no helpers here.
  mylib = { };

  baseSystemModules = [
    {
      nixpkgs.overlays = [
        self.overlays.default
        inputs.nix-alien.overlays.default
      ];
    }
  ];

  # Binds the HM user only; shared HM settings live in `tools/home-manager.nix`.
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
          # HM + agenix come from composition; factory binds the HM user only.
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
