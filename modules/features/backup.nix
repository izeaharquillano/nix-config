{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.myfeatures.backup;
in
{
  options.myfeatures.backup = {
    enable = lib.mkEnableOption "Restic backups";
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ config.users.users.ize.home ];
      defaultText = lib.literalExpression "[ config.users.users.ize.home ]";
      description = "Paths to back up.";
    };
    repository = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/backup/restic-repo";
      description = "Restic repository path.";
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ".cache"
        ".local/share/Trash"
        "node_modules"
        ".cargo/registry"
      ];
      description = "Paths to exclude from backup.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups = {
      btrfs = {
        paths = cfg.paths;
        exclude = cfg.exclude;
        repository = cfg.repository;
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
