{
  lib,
  stdenv,
  cmake,
  pkg-config,
  glib,
  systemd,
  dbus,
  gtk3,
  libdbusmenu-gtk3,
  libx11,
  wayland,
  src ? ./.,
}:

stdenv.mkDerivation {
  pname = "appmenu-gtk-module-wayland";
  version = "unstable-2026-11-04";

  inherit src;

  nativeBuildInputs = [
    cmake
    pkg-config
    glib # provides glib-compile-schemas, which CMake runs at install time
    systemd
    dbus
  ];

  buildInputs = [
    gtk3
    libdbusmenu-gtk3 # provides dbusmenu-gtk3-0.4 and dbusmenu-glib-0.4
    libx11
    wayland
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    # Keep the profile script inside the package; the NixOS module below
    # exposes it through /etc/profile.d.
    "-DPROFILE_INSTALL_DIR=etc/profile.d"
    "-DBUILD_TESTS=OFF"
  ];

  # The upstream CMake install script compiles the schema when DESTDIR is
  # empty. Run it again here as a safeguard for staged/package installs.
  postInstall = ''
    glib-compile-schemas --strict "$out/share/glib-2.0/schemas"
  '';

  meta = {
    description = "GTK 3 global-menu module for Plasma Wayland";
    homepage = "https://github.com/yonikek/appmenu-gtk-module-wayland";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
  };
}
