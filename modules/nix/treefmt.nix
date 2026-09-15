# Per-system fmt/checks/shell/apps (`pkgs` from `modules/nix/nixpkgs.nix`,
# intentionally free-only; target systems get unfree via `system/nix.nix`).
# Per-host eval covered by CI dry-builds, not a `perSystem` check.
{ inputs, self, ... }:
{
  perSystem =
    {
      system,
      pkgs,
      ...
    }:
    let
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        programs.shfmt.enable = true;
      };

      preCommitEval = inputs.pre-commit-hooks.lib.${system}.run {
        src = self;
        excludes = [
          "secrets/.*\\.age$"
          "_img/.*"
        ];
        hooks = {
          # nixfmt lives in treefmt (`nix fmt` + `checks.formatting`) — not duplicated here.
          statix.enable = true;
          deadnix.enable = true;
        };
      };
    in
    {
      formatter = treefmtEval.config.build.wrapper;

      checks = {
        formatting = treefmtEval.config.build.check self;
        pre-commit = preCommitEval;
      };

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
            pkgs.jq # `just ci-dry-build` parses `nix eval --json`
            pkgs.deadnix
            pkgs.statix
          ];
        };
      };
    };
}
