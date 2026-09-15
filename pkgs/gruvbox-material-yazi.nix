{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "gruvbox-material-yazi";
  version = "unstable-e0fd2d8";
  src = fetchFromGitHub {
    owner = "matt-dong-123";
    repo = "gruvbox-material.yazi";
    rev = "e0fd2d800aeb6adb680496b1a5ef125b901b7413";
    hash = "sha256-mfIdFIe++jRDbTQBcLlpAq91JzmgL2SvqPxkYuCnKdQ=";
  };
  dontConfigure = true;
  dontBuild = true;
  # Keep the upstream tree layout (`flavor.toml` at root) so
  # `programs.yazi.flavors` consumes it unchanged.
  installPhase = ''
    runHook preInstall
    cp -r $src $out
    runHook postInstall
  '';
  meta = {
    description = "Gruvbox Material flavor for Yazi";
    homepage = "https://github.com/matt-dong-123/gruvbox-material.yazi";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
