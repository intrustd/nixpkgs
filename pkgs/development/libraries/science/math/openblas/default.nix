{ stdenv, fetchFromGitHub, fetchpatch, gfortran, perl, which, config, coreutils
, buildPackages
# Most packages depending on openblas expect integer width to match
# pointer width, but some expect to use 32-bit integers always
# (for compatibility with reference BLAS).
, blas64 ? null, openmp ? true
}:

with stdenv.lib;

let blas64_ = blas64; enableOpenMp = if openmp then "1" else "0";

    isCross = stdenv.hostPlatform != stdenv.buildPlatform;
    AR = if isCross then "${stdenv.hostPlatform.config}-ar" else "ar";
    CC = if isCross then "${stdenv.hostPlatform.config}-cc" else "gcc";
    FC = if isCross then "${stdenv.hostPlatform.config}-gfortran" else "gfortran";
    RANLIB = if isCross then "${stdenv.hostPlatform.config}-ranlib" else "ranlib";
in

let
  # To add support for a new platform, add an element to this set.
  configs = {
    armv6l-linux = {
      BINARY = "32";
      TARGET = "ARMV6";
      DYNAMIC_ARCH = "0";
      USE_OPENMP = enableOpenMp;
      inherit AR CC;
    };

    armv7l-linux = {
      BINARY = "32";
      TARGET = "ARMV7";
      DYNAMIC_ARCH = "0";
      USE_OPENMP = enableOpenMp;
      inherit AR CC;
    };

    aarch64-linux = {
      BINARY = "64";
      TARGET = "ARMV8";
      DYNAMIC_ARCH = "1";
      USE_OPENMP = enableOpenMp;
      inherit AR CC;
    };

    i686-linux = {
      BINARY = "32";
      TARGET = "P2";
      DYNAMIC_ARCH = "1";
      USE_OPENMP = "1";
      inherit AR CC;
    };

    x86_64-darwin = {
      BINARY = "64";
      TARGET = "ATHLON";
      DYNAMIC_ARCH = "1";
      # Note that clang is available through the stdenv on OSX and
      # thus is not an explicit dependency.
      CC = "clang";
      USE_OPENMP = "0";
      MACOSX_DEPLOYMENT_TARGET = "10.7";
    };

    x86_64-linux = {
      BINARY = "64";
      TARGET = "ATHLON";
      DYNAMIC_ARCH = "1";
      USE_OPENMP = enableOpenMp;
      inherit AR CC;
    };
  };
in

let
  config =
    configs.${stdenv.hostPlatform.system}
    or (throw "unsupported system: ${stdenv.hostPlatform.system}");
in

let
  blas64 =
    if blas64_ != null
      then blas64_
      else hasPrefix "x86_64" stdenv.hostPlatform.system;
in
stdenv.mkDerivation rec {
  name = "openblas-${version}";
  version = "0.3.3";
  src = fetchFromGitHub {
    owner = "xianyi";
    repo = "OpenBLAS";
    rev = "v${version}";
    sha256 = "0cpkvfvc14xm9mifrm919rp8vrq70gpl7r2sww4f0izrl39wklwx";
  };

  inherit blas64;

  # Some hardening features are disabled due to sporadic failures in
  # OpenBLAS-based programs. The problem may not be with OpenBLAS itself, but
  # with how these flags interact with hardening measures used downstream.
  # In either case, OpenBLAS must only be used by trusted code--it is
  # inherently unsuitable for security-conscious applications--so there should
  # be no objection to disabling these hardening measures.
  hardeningDisable = [
    # don't modify or move the stack
    "stackprotector" "pic"
    # don't alter index arithmetic
    "strictoverflow"
    # don't interfere with dynamic target detection
    "relro" "bindnow"
  ];

  nativeBuildInputs =
    [gfortran perl which]
    ++ optionals stdenv.isDarwin [coreutils];

  makeFlags =
    [
      "FC=${FC}"
      "RANLIB=${RANLIB}"
      ''PREFIX="''$(out)"''
      "NUM_THREADS=64"
      "INTERFACE64=${if blas64 then "1" else "0"}"
      "NO_STATIC=1"
    ] ++ stdenv.lib.optional (stdenv.hostPlatform.libc == "musl") "NO_AFFINITY=1"
    ++ mapAttrsToList (var: val: var + "=" + val) config;

    patches = [];

  doCheck = true;
  checkTarget = "tests";

  postInstall = ''
    # Write pkgconfig aliases. Upstream report:
    # https://github.com/xianyi/OpenBLAS/issues/1740
    for alias in blas cblas lapack; do
      cat <<EOF > $out/lib/pkgconfig/$alias.pc
Name: $alias
Version: ${version}
Description: $alias provided by the OpenBLAS package.
Cflags: -I$out/include
Libs: -L$out/lib -lopenblas
EOF
    done
  '';

  meta = with stdenv.lib; {
    description = "Basic Linear Algebra Subprograms";
    license = licenses.bsd3;
    homepage = https://github.com/xianyi/OpenBLAS;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ttuegel ];
  };

  # We use linkName to pass a different name to --with-blas-libs for
  # fflas-ffpack and linbox, because we use blas on darwin but openblas
  # elsewhere.
  # See see https://github.com/NixOS/nixpkgs/pull/45013.
  passthru.linkName = "openblas";
}
