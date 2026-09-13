# Per-system outputs: formatting, checks, dev shell, and flake apps.
# Migrated from `outputs/default.nix` into the dendritic `perSystem` pattern.
{ inputs, self, ... }:
let
  forSystem = system: inputs.nixpkgs.legacyPackages.${system};
in
{
  perSystem =
    { system, ... }:
    let
      pkgs = forSystem system;

      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        programs.shfmt.enable = true;
      };

      preCommitEval = inputs.pre-commit-hooks.lib.${system}.run {
        src = self;
        hooks = {
          nixfmt.enable = true;
        };
      };

      hostEvalChecks = inputs.nixpkgs.lib.mapAttrs' (name: cfg: {
        name = "${name}-eval";
        value = pkgs.runCommand "check-${name}-eval" { } ''
          [ -n "${cfg.config.networking.hostName}" ] || exit 1
          [ -n "${cfg.config.system.stateVersion}" ] || exit 1
          echo "ok" > $out
        '';
      }) self.nixosConfigurations;
    in
    {
      formatter = treefmtEval.config.build.wrapper;

      checks = {
        formatting = treefmtEval.config.build.check self;
        pre-commit = preCommitEval;
      }
      // hostEvalChecks;

      apps = {
        agenix = {
          type = "app";
          program = "${inputs.agenix.packages.${system}.default}/bin/agenix";
          meta.description = "Secret management with age";
        };
      };

      devShells = {
        default = pkgs.mkShell {
          inputsFrom = [ treefmtEval.config.build.devShell ];
          packages = [
            inputs.agenix.packages.${system}.default
            pkgs.just
            pkgs.nixfmt
            pkgs.deadnix
            pkgs.statix
          ];
        };
      };
    };
}
