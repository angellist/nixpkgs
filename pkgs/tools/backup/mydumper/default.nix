{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, sphinx, glib, pcre
, libmysqlclient, libressl, zlib, zstd }:

stdenv.mkDerivation rec {
  pname = "mydumper";
  version = "0.15.2-4";

  src = fetchFromGitHub {
    owner = "mydumper";
    repo = "mydumper";
    rev = "refs/tags/v${version}";
    hash = "sha256-j2qUvjVl7XXOM3fnicjkHkW9jjyEV0v6FClfgqDemLA=";
  };

  patches = lib.optionals stdenv.isDarwin [ ./darwin.patch ];

  outputs = [ "out" "doc" "man" ];

  nativeBuildInputs = [ cmake pkg-config sphinx ];

  buildInputs = [ glib pcre libmysqlclient libressl zlib zstd ];

  env.NIX_CFLAGS_COMPILE =
    toString (lib.optionals stdenv.isDarwin [ "-Wno-sometimes-uninitialized" ]);

  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    "-DMYSQL_INCLUDE_DIR=${lib.getDev libmysqlclient}/include/mysql"
    "-DWITH_ZSTD=ON"
  ];

  meta = with lib; {
    description = "High-performance MySQL backup tool";
    homepage = "https://github.com/maxbube/mydumper";
    changelog = "https://github.com/mydumper/mydumper/releases/tag/v${version}";
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ izorkin ];
  };
}
