{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  buildKodiAddon,
  autoPatchelfHook,
  python3,
}:

let
  platformDetect = fetchFromGitHub {
    owner = "ElementumOrg";
    repo = "platform_detect";

    # Prefer a fixed commit rather than master.
    rev = "effb836";
    hash = "sha256-6jtMktB6MR35WucRi8ZVdO3kyEpQEpdhqPYBI0uSk04=";
  };
  elementumBinary = fetchurl {
    url = "https://raw.githubusercontent.com/elgatito/elementum-binaries/master/linux_x64/elementum";
    hash = "sha256-hZ0K9tR07qvwrby1PlCEDggXWvD3dlilVFJ/8VPqjmQ=";
  };
  elementumLibrary = fetchurl {
    url = "https://raw.githubusercontent.com/elgatito/elementum-binaries/master/linux_x64/elementum.so";
    hash = "sha256-TXQAD3+s/oiH1CJuFiY8YVqqp9itBNyVZCNoojsr8Qk=";
  };
  elementumHeader = fetchurl {
    url = "https://raw.githubusercontent.com/elgatito/elementum-binaries/master/linux_x64/elementum.h";
    hash = "sha256-bwtrzGCJQauaMy4EfcE80iRnPxdHvFkHXC7Rkd0gpik=";
  };
  elementumLicense = fetchurl {
    url = "https://raw.githubusercontent.com/fugkco/repository.elementumorg/refs/heads/master/LICENSE";
    hash = "sha256-5u/KXjuHRG7sgI13wSvVzwoaiqDN4HVBxUao0oK7rFs=";
  };
in
buildKodiAddon rec {
  pname = "elementum";
  namespace = "plugin.video.elementum";
  version = "0.1.114";

  src = fetchFromGitHub {
    owner = "elgatito";
    repo = "plugin.video.elementum";
    tag = "v${version}";
    hash = "sha256-tozRvFVsxJfW+ew3HL0N8O4Vw3l+slEtV9/uRvJwg88=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  postPatch = ''
    mkdir -p resources/site-packages/platform_detect

    cp -r ${platformDetect}/python/. \
      resources/site-packages/platform_detect/

    cp -r ${platformDetect}/libraries \
      resources/site-packages/platform_detect/

    substituteInPlace resources/site-packages/elementum/daemon.py \
      --replace-fail \
        'elementum_dir, elementum_binary = get_elementum_binary()' \
        'elementum_dir = os.path.join(ADDON_PATH, "resources", "bin", "linux_x64")
        elementum_binary = os.path.join(elementum_dir, "elementum")
        binary_platform = get_platform()'
  '';

  buildPhase = "true";

  installPhase = ''
    mkdir -p "$out/share/kodi/addons/${namespace}"

    cp -r ./* \
      "$out/share/kodi/addons/${namespace}/"

    rm -rf \
      "$out/share/kodi/addons/${namespace}/resources/bin"

    mkdir -p \
      "$out/share/kodi/addons/${namespace}/resources/bin/linux_x64"

    cp -r \
      "$src/resources/bin/linux_x64/"* \
      "$out/share/kodi/addons/${namespace}/resources/bin/linux_x64/"

    install -Dm 0755 \
      ${elementumBinary}  "$out/share/kodi/addons/${namespace}/resources/bin/linux_x64/elementum"
    install -Dm 0755 \
      ${elementumLibrary} "$out/share/kodi/addons/${namespace}/resources/bin/linux_x64/elementum.so"
    install -Dm 0755 \
      ${elementumHeader}  "$out/share/kodi/addons/${namespace}/resources/bin/linux_x64/elementum.h"

    install -Dm 0755 \
      ${elementumLicense}  "$out/share/kodi/addons/repository.elementumorg/License"
  '';

  meta = {
    homepage = "https://github.com/elgatito/plugin.video.elementum";
    description = "Torrent streaming engine for Kodi";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
