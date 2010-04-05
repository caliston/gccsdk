--- libiberty/configure.ac.orig	2010-04-05 17:22:10.590958470 +0200
+++ libiberty/configure.ac	2010-04-05 17:21:54.468455261 +0200
@@ -109,9 +109,34 @@ dnl to call AC_CHECK_PROG.
 AC_CHECK_TOOL(AR, ar)
 AC_CHECK_TOOL(RANLIB, ranlib, :)
 
+dnl When switching to automake, replace the following with AM_ENABLE_MULTILIB.
+# Add --enable-multilib to configure.
+# Default to --enable-multilib
+AC_ARG_ENABLE(multilib,
+[  --enable-multilib       build many library versions (default)],
+[case "$enableval" in
+  yes) multilib=yes ;;
+  no)  multilib=no ;;
+  *)   AC_MSG_ERROR([bad value $enableval for multilib option]) ;;
+ esac],
+             [multilib=yes])
+
+# Even if the default multilib is not a cross compilation,
+# it may be that some of the other multilibs are.
+if test $cross_compiling = no && test $multilib = yes \
+   && test "x${with_multisubdir}" != x ; then
+   cross_compiling=maybe
+fi
+
 GCC_NO_EXECUTABLES
+
+m4_rename([_AC_ARG_VAR_PRECIOUS],[real_PRECIOUS])
+m4_define([_AC_ARG_VAR_PRECIOUS],[])
 AC_PROG_CC
 AC_PROG_CPP_WERROR
+m4_rename([real_PRECIOUS],[_AC_ARG_VAR_PRECIOUS])
+AC_SUBST(CFLAGS)
+AC_SUBST(CPPFLAGS)
 
 if test x$GCC = xyes; then
   ac_libiberty_warn_cflags='-W -Wall -pedantic -Wwrite-strings -Wstrict-prototypes'
