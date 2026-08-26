{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto";
    cores = 0;
    http-connections = 50;
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  nix.extraOptions = ''
    !include /etc/nix/github-token.conf
  '';
}
