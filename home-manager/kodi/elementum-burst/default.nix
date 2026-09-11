{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
}:

buildKodiAddon rec {
  pname = "elementum-burst";
  namespace = "script.elementum.burst";
  version = "0.0.99";

  src = fetchFromGitHub {
    owner = "elgatito";
    repo = "script.elementum.burst";
    tag = "v${version}";
    hash = "sha256-EnE/NAMOMznsfC5wbD2keZ8aL6f8b+44iTGnU9bv+Sw=";
  };

  meta = {
    homepage = "https://github.com/elgatito/script.elementum.burst";
    description = "Burst provider addon for Elementum";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
