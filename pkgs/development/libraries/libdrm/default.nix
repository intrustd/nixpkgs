{ stdenv, fetchurl, pkgconfig, libpthreadstubs, libpciaccess, valgrind-light,
  testsSupport ? false }:

stdenv.mkDerivation rec {
  name = "libdrm-2.4.94";

  src = fetchurl {
    url = "https://dri.freedesktop.org/libdrm/${name}.tar.bz2";
    sha256 = "1ghn3l1dv1rsp9z6jpmy4ryna1s8rm4xx0ds532041bnlfq5jg5p";
  };

  outputs = [ "out" "dev" "bin" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libpthreadstubs libpciaccess ] ++ stdenv.lib.optional testsSupport valgrind-light;
    # libdrm as of 2.4.70 does not actually do anything with udev.

  doCheck = testsSupport;

  patches = stdenv.lib.optional stdenv.isDarwin ./libdrm-apple.patch;

  postPatch = ''
    for a in */*-symbol-check ; do
      patchShebangs $a
    done
  '';

  preConfigure = stdenv.lib.optionalString stdenv.isDarwin
    "echo : \\\${ac_cv_func_clock_gettime=\'yes\'} > config.cache";

  configureFlags = [ "--enable-install-test-programs" ]
    ++ stdenv.lib.optionals (stdenv.isAarch32 || stdenv.isAarch64)
      [ "--enable-tegra-experimental-api" "--enable-etnaviv-experimental-api" ]
    ++ stdenv.lib.optional stdenv.isDarwin "-C"
    ++ stdenv.lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) "--disable-intel"
    ;

  meta = {
    homepage = https://dri.freedesktop.org/libdrm/;
    description = "Library for accessing the kernel's Direct Rendering Manager";
    license = "bsd";
    platforms = stdenv.lib.platforms.unix;
  };
}
