{
  lib,
  config,
  ...
}:

let
  cfg = config.myfeatures.docker;
in
{
  options.myfeatures.docker = {
    enable = lib.mkEnableOption "Docker container runtime";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = false;
      autoPrune.enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    users.users.${config.mySystem.username}.linger = true;
  };
}
