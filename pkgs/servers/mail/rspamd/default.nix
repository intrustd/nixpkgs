{ stdenv, lib, fetchFromGitHub, cmake, perl, openblasCompat
, file, glib, gmime, libevent, luajit, openssl, pcre, pkgconfig, sqlite, ragel, icu, libfann }:

let libmagic = file;  # libmagic provided by file package ATM
    tryRunGuesses = [ "HAVE_ATOMIC_BUILTINS" "HAS_C11_ATOMICS"
                      "BLAS_F2C_DOUBLE_WORKS" "BLAS_F2C_FLOAT_WORKS" ] ++
      lib.optionals stdenv.hostPlatform.isx86 [
        "HAVE_RDTSC" "C_HAS_SSE1_1" "C_HAS_SSE2_1"
        "C_HAS_SSE3_1" "C_HAS_SSE3_2"
        "C_HAS_SSE4_1_1" "C_HAS_SSE4_1_2"
        "C_HAS_SSE4_2_1" "C_HAS_SSE4_2_2"
        "C_HAS_AVX_1" "C_HAS_AVX_2" "C_HAS_AVX2_1" "C_HAS_AVX2_2"
        "CXX_HAS_SSE1_1" "CXX_HAS_SSE2_1" "CXX_HAS_SSE3_1" "CXX_HAS_SSE3_2"
        "CXX_HAS_SSE4_1_1" "CXX_HAS_SSE4_1_2" "CXX_HAS_SSE4_2_1" "CXX_HAS_SSE4_2_2"
        "CXX_HAS_AVX_1" "CXX_HAS_AVX_2" "CXX_HAS_AVX2_1" "CXX_HAS_AVX2_2"
      ];
in

stdenv.mkDerivation rec {
  name = "rspamd-${version}";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "vstakhov";
    repo = "rspamd";
    rev = version;
    sha256 = "02q1id9kv5d6w1b1ifa2m6qrnbsja787dn0ywwi0yrsaqwk63wk7";
  };

  nativeBuildInputs = [ cmake pkgconfig perl ];
  buildInputs = [ glib gmime libevent libmagic luajit openssl pcre sqlite ragel icu libfann openblasCompat ];

  patches = lib.optional stdenv.hostPlatform.isMusl ./musl-compile.patch;

  cmakeFlags = lib.flatten [
    "-DDEBIAN_BUILD=ON"
    "-DRUNDIR=/var/run/rspamd"
    "-DDBDIR=/var/lib/rspamd"
    "-DLOGDIR=/var/log/rspamd"
    "-DLOCAL_CONFDIR=/etc/rspamd"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) (
     [ "-D_CAN_RUN=advanced" ] ++
     (map (x: ["-D${x}_EXITCODE=0" "-D${x}_EXITCODE__TRYRUN_OUTPUT=advanced" ]) (lib.flatten tryRunGuesses))
  );

  meta = with stdenv.lib; {
    homepage = https://github.com/vstakhov/rspamd;
    license = licenses.asl20;
    description = "Advanced spam filtering system";
    maintainers = with maintainers; [ avnik fpletz ];
    platforms = with platforms; linux;
  };
}
