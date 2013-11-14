AC_PREREQ([2.68])
AC_INIT([submarine], [0.1.7], [blaz.tomazic@gmail.com])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([foreign -Wall -Werror -Wno-extra-portability])
AM_SILENT_RULES([yes])
AC_CONFIG_FILES([Makefile
				 lib/Makefile
				 submarine/Makefile
				 doc/Makefile])

# Checks for programs.
AM_PROG_AR
LT_INIT

AC_PROG_CC
AM_PROG_CC_C_O

AM_PROG_VALAC

PKG_PROG_PKG_CONFIG

# Checks for libraries.
libsubmarine_modules="glib-2.0 gobject-2.0 libsoup-2.4 gee-0.8 libarchive libxml-2.0"
PKG_CHECK_MODULES([LIBSUBMARINE], [$libsubmarine_modules])
AC_SUBST([LIBSUBMARINE_CFLAGS])
AC_SUBST([LIBSUBMARINE_LIBS])
LIBSUBMARINE_VALAPACKAGES="--pkg gee-0.8 --pkg libsoup-2.4 --pkg libarchive --pkg libxml-2.0"
AC_SUBST([LIBSUBMARINE_VALAPACKAGES])

submarine_modules="$libsubmarine_modules gio-2.0"
PKG_CHECK_MODULES([SUBMARINE], [$submarine_modules])
AC_SUBST([SUBMARINE_CFLAGS])
AC_SUBST([SUBMARINE_LIBS])
SUBMARINE_VALAPACKAGES="--pkg gee-0.8 --pkg gio-2.0"
AC_SUBST([SUBMARINE_VALAPACKAGES])

AC_OUTPUT
