{ stdenv, lib, fetchurl, fetchFromGitHub, libiconv, recode, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "enca-${version}";
  version = "1.19";

  src = if stdenv.hostPlatform != stdenv.buildPlatform
    then fetchFromGitHub {
      owner = "nijel";
      repo = "enca";
      rev = "5de465b25a7e5dd432bf9b10f253391a1139e1c4";
      sha256 = "0z5zlm6m0s0czx96ih5779cdaa4p84lqjxj6fb4ppv8ncp1nibdd";
    }
    else fetchurl {
      url = "https://dl.cihar.com/enca/${name}.tar.xz";
      sha256 = "1f78jmrggv3jymql8imm5m9yc8nqjw5l99mpwki2245l8357wj1s";
    };

  patches = lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    (fetchpatch {
      url = "https://github.com/nijel/enca/commit/2393833d133a6784e57215b89e4c4c0484555985.patch";
      sha256 = "05m70lfmkxlhpigxg0yhs1v2wlb21bw62dgxsca2pnm0s0qznplb";
    })
    (fetchpatch {
      url = "https://github.com/nijel/enca/commit/a38b8cec1f48dc6325450d097060c16ba0682d78.patch";
      sha256 = "1zwpdx9sg3jy00rjhpvqwdgr3bgnkk4dpq8dmj1zjzm8sz0zm2cd";
     })
  ];

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
