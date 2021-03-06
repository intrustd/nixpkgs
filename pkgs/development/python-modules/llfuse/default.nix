{ stdenv, fetchurl, buildPythonPackage, pkgconfig, pytest, fuse, attr, which
, contextlib2, buildPackages
}:

buildPythonPackage rec {
  pname = "llfuse";
  version = "1.3.5";
  name = pname + "-" + version;

  src = fetchurl {
    url = "mirror://pypi/l/llfuse/${name}.tar.bz2";
    sha256 = "6e412a3d9be69162d49b8a4d6fb3c343d1c1fba847f4535d229e0ece2548ead8";
  };

  # need to explicitly scope, otherwise, we bring in the python pkgconfig package
  nativeBuildInputs = [ buildPackages.pkgconfig ];
  buildInputs = [ pytest fuse attr which ];

  propagatedBuildInputs = [ contextlib2 ];

  checkPhase = ''
    py.test
  '';

  # FileNotFoundError: [Errno 2] No such file or directory: '/usr/bin'
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Python bindings for the low-level FUSE API";
    homepage = https://code.google.com/p/python-llfuse/;
    license = licenses.lgpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ bjornfor ];
  };
}
