{ pkgs, lib, config, ... }:

let
  cfg = config.myfeatures.backup;
in
{
  options.myfeatures.backup = {
    enable = lib.mkEnableOption "Restic backups with BTRFS snapshot integration";
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups = {
      btrfs = {
        paths = [
          "/home/ize"
        ];
        exclude = [
          ".cache"
          ".local/share/Trash"
          "node_modules"
          ".cargo/registry"
        ];
        repository = "/mnt/backup/restic-repo";
        passwordFile = "/etc/restic/password";
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      restic
    ];
  };
}
