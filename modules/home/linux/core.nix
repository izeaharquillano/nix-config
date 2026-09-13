# Inheritance Aspect: headless home configuration (no GUI).
# Dendritic module: flake.modules.homeManager.home-linux-core
{ inputs, ... }:
{
  flake.modules.homeManager.home-linux-core = {
    imports = with inputs.self.modules.homeManager; [
      user-ize
      home-core-shell
      home-core-cli
      home-core-dev
      home-core-terminal
      home-core-nvim
      home-core-notes
      home-linux-desktop
      home-linux-utils
    ];
  };
}
