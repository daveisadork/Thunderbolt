dnl Process this file with autoconf to produce a configure script.
dnl Created by Anjuta application wizard.

AC_INIT(thunderbolt, 0.1, , thunderbolt)
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

AM_INIT_AUTOMAKE(AC_PACKAGE_NAME, AC_PACKAGE_VERSION)
AC_CONFIG_HEADERS([config.h])
AM_MAINTAINER_MODE

AC_PROG_CC


AM_PROG_LIBTOOL


dnl Check for vala
AM_PROG_VALAC([0.10.0])


PKG_CHECK_MODULES(THUNDERBOLT, gnome-keyring-1
libsoup-gnome-2.4
webkitgtk-3.0
[gtk+-3.0 gio-2.0 glib-2.0 gdk-pixbuf-2.0 libsoup-2.4 gdk-3.0])


AC_OUTPUT([
Makefile
src/Makefile

])
