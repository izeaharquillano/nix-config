# Obsidian vault (GUI-only); path must match p2p Obsidian folder (`vars.obsidianVaultRel`).
{
  flake.modules.homeManager.notes =
    { vars, ... }:
    {
      programs.obsidian = {
        enable = true;
        vaults.notes.target = vars.obsidianVaultRel;
      };
    };
}
