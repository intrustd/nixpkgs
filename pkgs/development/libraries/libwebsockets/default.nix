{ fetchFromGitHub, stdenv, lib, cmake, openssl, zlib, libuv }:

stdenv.mkDerivation rec {
  name = "libwebsockets-${version}";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "warmcat";
    repo = "libwebsockets";
    rev = "v${version}";
    sha256 = "1x3qrz2hqsrv2lg0y9irdx37c8r9j9vf9mwzgw61znzvk6hc9ymq";
  };

  buildInputs = [ openssl zlib libuv ];
  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DLWS_WITH_PLUGINS=ON" ] ++
               lib.optional (stdenv.hostPlatform.config != stdenv.buildPlatform.config)
                 "-DLWS_WITHOUT_TEST_SERVER=ON";

  meta = {
    description = "Light, portable C library for websockets";
    longDescription = ''
      Libwebsockets is a lightweight pure C library built to
      use minimal CPU and memory resources, and provide fast
      throughput in both directions.
    '';
    homepage = https://libwebsockets.org;
    license = stdenv.lib.licenses.lgpl21;
    platforms = stdenv.lib.platforms.all;
  };
}
