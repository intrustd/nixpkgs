{ stdenv, lib, fetchurl, fetchpatch, libiconv, recode }:

stdenv.mkDerivation rec {
  name = "enca-${version}";
  version = "1.19";

  src = fetchurl {
    url = "https://dl.cihar.com/enca/${name}.tar.xz";
    sha256 = "1f78jmrggv3jymql8imm5m9yc8nqjw5l99mpwki2245l8357wj1s";
  };
  
  patches = lib.optional (stdenv.hostPlatform != stdenv.buildPlatform)
    (fetchpatch {
      url = "https://github.com/nijel/enca/commit/2393833d133a6784e57215b89e4c4c0484555985.patch";
      sha256 = "1m46b7dipph0nk4vfl7kdniyc6g2vjldzi2qxwm4s3r2qr65q4q7";
    });

  buildInputs = [ recode libiconv ];

  meta = with stdenv.lib; {
    description = "Detects the encoding of text files and reencodes them";

    longDescription = ''
        Enca detects the encoding of text files, on the basis of knowledge
        of their language. It can also convert them to other encodings,
        allowing you to recode files without knowing their current encoding.
        It supports most of Central and East European languages, and a few
        Unicode variants, independently on language.
    '';

    license = licenses.gpl2;
   
  };
}
