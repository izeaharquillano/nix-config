# Root/system tools only (`efibootmgr` needs EFI access); per-user CLIs
# belong in HM (`homeManager.cli`).
{
  flake.modules.nixos.packages =
    { pkgs, ... }:

    {
      environment.systemPackages = [
        pkgs.efibootmgr
      ];
    };
}
