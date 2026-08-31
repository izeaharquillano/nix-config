final: prev: {
  gruvbox-material-yazi = final.callPackage ../pkgs/gruvbox-material-yazi.nix { };

  # Pin specific package versions:
  # my-package = prev.my-package.overrideAttrs (old: {
  #   version = "1.2.3";
  #   src = prev.fetchurl {
  #     url = "https://example.com/package-1.2.3.tar.gz";
  #     sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  #   };
  # });
}
