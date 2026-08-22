{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
  '';
}
