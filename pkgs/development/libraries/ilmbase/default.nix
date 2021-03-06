{ stdenv, fetchurl, automake, autoconf, libtool, which, buildPackages }:

stdenv.mkDerivation rec {
  name = "ilmbase-${version}";
  version = "2.3.0";

  src = fetchurl {
    url = "https://github.com/openexr/openexr/releases/download/v${version}/${name}.tar.gz";
    sha256 = "0qiq5bqq9rxhqjiym2k36sx4vq8adgrz6xf6qwizi9bqm78phsa5";
  };

  outputs = [ "out" "dev" ];

  preConfigure = ''
    patchShebangs ./bootstrap
    ./bootstrap
  '';

  nativeBuildInputs = [ automake autoconf libtool which ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  NIX_CFLAGS_LINK = [ "-pthread" ];

  patches = [ ./bootstrap.patch
              ./ilmbase-2.3.0-cross-compile.patch ];

  # fails 1 out of 1 tests with
  # "lt-ImathTest: testBoxAlgo.cpp:892: void {anonymous}::boxMatrixTransform(): Assertion `b21 == b2' failed"
  # at least on i686. spooky!
  doCheck = stdenv.isx86_64;

  meta = with stdenv.lib; {
    homepage = http://www.openexr.com/;
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}
