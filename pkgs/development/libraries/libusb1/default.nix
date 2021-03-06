{ stdenv, lib, fetchurl, pkgconfig, systemd ? null, udev ? null, libobjc, IOKit
, systemdSupport ? stdenv.isLinux }:

stdenv.mkDerivation rec {
  name = "libusb-1.0.22";

  src = fetchurl {
    url = "mirror://sourceforge/libusb/${name}.tar.bz2";
    sha256 = "0mw1a5ss4alg37m6bd4k44v35xwrcwp5qm4s686q1nsgkbavkbkm";
  };

  outputs = [ "out" "dev" ]; # get rid of propagating systemd closure

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs =
    stdenv.lib.optional systemdSupport systemd ++
    lib.optional (!(isNull udev)) udev ++
    stdenv.lib.optionals stdenv.isDarwin [ libobjc IOKit ];

  NIX_LDFLAGS = stdenv.lib.optionalString stdenv.isLinux "-lgcc_s";

  preFixup = stdenv.lib.optionalString stdenv.isLinux ''
    sed 's,-ludev,-L${lib.getLib udev}/lib -ludev,' -i $out/lib/libusb-1.0.la
  '';

  meta = with stdenv.lib; {
    homepage = "https://libusb.info/";
    repositories.git = "https://github.com/libusb/libusb";
    description = "cross-platform user-mode USB device library";
    longDescription = ''
      libusb is a cross-platform user-mode library that provides access to USB devices.
    '';
    platforms = platforms.all;
    license = licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
