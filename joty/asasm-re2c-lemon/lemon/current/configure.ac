#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.64])
AC_INIT([lemon], [1.00], [http://gccsdk.riscos.info/])
AC_CONFIG_SRCDIR([lemon.c])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([-Wall foreign])
dnl Support silent build rules.
dnl Disable by either passing --disable-silent-rules to configure
dnl or passing V=1 to make
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_FUNC_STRTOD
AC_CHECK_FUNCS([memset strchr strrchr strtol])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
