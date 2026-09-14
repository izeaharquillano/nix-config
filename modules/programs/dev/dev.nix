# lazygit, git identity, npm (no compilers here; use a devShell).
{
  flake.modules.homeManager.dev =
    { pkgs, vars, ... }:

    {
      home.packages = [
        pkgs.lazygit
        pkgs.opencode
      ];

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = vars.userfullname;
            email = vars.useremail;
          };
        };
      };

      programs.npm.enable = true;
    };
}
