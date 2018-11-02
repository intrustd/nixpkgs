{ stdenv, fetchFromGitHub, pkgconfig, qmake, qtsvg, qttools,
  qtx11extras, xkeyboard_config, xorg, lightdm_qt, gsettings-qt,
  dde-qt-dbus-factory, deepin-gettext-tools, dtkcore, dtkwidget,
  hicolor-icon-theme }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "dde-session-ui";
  version = "4.5.1.10";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "0cr3g9jbgpp8k41i86lr4pg88gn690nzili7ah745vf1kdwvi1w0";
  };

  nativeBuildInputs = [
    pkgconfig
    qmake
    qttools
    deepin-gettext-tools
  ];

  buildInputs = [
    dde-qt-dbus-factory
    dtkcore
    dtkwidget
    gsettings-qt
    lightdm_qt
    qtsvg
    qtx11extras
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXtst
    xkeyboard_config
    hicolor-icon-theme
  ];

  postPatch = ''
    patchShebangs .
    sed -i translate_desktop.sh -e "s,/usr/bin/deepin-desktop-ts-convert,deepin-desktop-ts-convert,"
    find -type f -exec sed -i -e "s,path = /etc,path = $out/etc," {} +
    find -type f -exec sed -i -e "s,path = /usr,path = $out," {} +
    find -type f -exec sed -i -e "s,Exec=/usr,Exec=$out," {} +
    find -type f -exec sed -i -e "s,/usr/share/dde-session-ui,$out/share/dde-session-ui," {} +
    sed -i global_util/xkbparser.h -e "s,/usr/share/X11/xkb/rules/base.xml,${xkeyboard_config}/share/X11/xkb/rules/base.xml,"
    sed -i lightdm-deepin-greeter/Scripts/lightdm-deepin-greeter -e "s,/usr/bin/lightdm-deepin-greeter,$out/bin/lightdm-deepin-greeter,"
    # fix default background url
    sed -i widgets/*.cpp boxframe/*.cpp -e 's,/usr/share/backgrounds/default_background.jpg,/usr/share/backgrounds/deepin/desktop.jpg,'
  '';

  meta = with stdenv.lib; {
    description = "Deepin desktop-environment - Session UI module";
    homepage = https://github.com/linuxdeepin/dde-session-ui;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };
}