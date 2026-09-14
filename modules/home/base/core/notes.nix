# Vault path must match the p2p Obsidian folder.
{
  flake.modules.homeManager.home-core-notes = {
    programs.obsidian = {
      enable = true;
      vaults.notes.target = "Documents/obsidian";
    };
  };
}
