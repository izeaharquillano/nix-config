# Simple Aspect: Obsidian vault
# Dendritic module: flake.modules.homeManager.home-core-notes
{
  flake.modules.homeManager.home-core-notes = {
    programs.obsidian = {
      enable = true;
      vaults.notes.target = "Documents/obsidian";
    };
  };
}
