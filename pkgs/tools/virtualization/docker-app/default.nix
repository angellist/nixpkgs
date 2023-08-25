{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "docker-app";
  version = "4.22.1";

  src = {
    x86_64-darwin = fetchurl {
      url = "https://desktop.docker.com/mac/main/amd64/118664/Docker.dmg";
      sha256 = "sha256-3MG6v6YHvp7rbvIhY1NSx9k5PHezg3wgbHaqAE2Wup0";
    };

    aarch64-darwin = fetchurl {
      url = "https://desktop.docker.com/mac/main/arm64/118664/Docker.dmg";
      sha256 = "sha256-pFJDOvJgR8kz512eZH0zr0G+wUy6e360/HpDz48O+ko=";
    };
  }.${stdenv.hostPlatform.system} or (throw
    "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Docker.app";

  # Docker.dmg cannot be extracted by undmg
  # https://github.com/matthewbauer/undmg/issues/6
  unpackCmd = ''
    if ! [[ "$curSrc" =~ \.dmg$ ]]; then return 1; fi
    mnt=$(mktemp -d -t ci-XXXXXXXXXX)

    function finish {
      /usr/bin/hdiutil detach $mnt -force
    }
    trap finish EXIT

    /usr/bin/hdiutil attach -nobrowse -noverify -noautofsck -readonly $src -mountpoint $mnt

    shopt -s extglob
    DEST="$PWD"
    (cd "$mnt"; cp -a !(Applications) "$DEST/")
  '';

  installPhase = ''
    mkdir -p "$out/Applications/Docker.app"
    cp -R . "$out/Applications/Docker.app"
    cp -R "$out/Applications/Docker.app/Contents/Resources/bin" "$out/bin"
  '';

  meta = {
    description = "Docker Desktop application";
    homepage = "https://docker.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
  };
}
