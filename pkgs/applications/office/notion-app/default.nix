{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "notion-app";
  version = "2.1.23";

  src = {
    x86_64-darwin = fetchurl {
      url = "https://desktop-release.notion-static.com/Notion-${version}.dmg";
      sha256 = "sha256-9K/BH2sVqaOrlPRUzzGgb9ZiXWMjeuzyf8HJAnOCgic=";
    };
    aarch64-darwin = fetchurl {
      url =
        "https://desktop-release.notion-static.com/Notion-${version}-arm64.dmg";
      sha256 = "sha256-wR/B2k2mQI2MBWmGpkp2WDEx7/aMPqUf7+2leFeINyk";
    };
  }.${stdenv.hostPlatform.system} or (throw
    "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Notion.app";

  installPhase = ''
    mkdir -p "$out/Applications/Notion.app"
    cp -R . "$out/Applications/Notion.app"
  '';

  meta = {
    description = "Notion Desktop client";
    homepage = "https://notion.so/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
  };
}
