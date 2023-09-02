{ lib, fetchurl, nodejs, stdenvNoCC, testers }:

stdenvNoCC.mkDerivation rec {
  pname = "pnpm";
  version = "8.6.12";

  src = fetchurl {
    url = "https://github.com/pnpm/pnpm/releases/download/v${version}/pnpm-macos-arm64";
    hash = "sha256-yrP9bWl/kagpI0kbzCSgrbEn43UeZhJtTp8v3z2p7cA";
  };

  unpackCmd = ''
    mkdir bin
    cp $src bin/pnpm
    chmod +x bin/pnpm
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -R . $out/bin
  '';

  meta = with lib; {
    description = "Fast, disk space efficient package manager";
    homepage = "https://pnpm.io";
    changelog = "https://github.com/pnpm/pnpm/releases/tag/v${version}";
    license = licenses.mit;
    platforms = nodejs.meta.platforms;
  };
}
