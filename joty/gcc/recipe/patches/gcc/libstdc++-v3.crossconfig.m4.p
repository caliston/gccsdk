Index: libstdc++-v3/crossconfig.m4
===================================================================
--- libstdc++-v3/crossconfig.m4	(revision 161061)
+++ libstdc++-v3/crossconfig.m4	(working copy)
@@ -198,6 +198,35 @@
     AC_DEFINE(HAVE_SINHF)
     AC_DEFINE(HAVE_SINHL)
     ;;
+  arm*-*-riscos*)
+    AC_CHECK_HEADERS([nan.h ieeefp.h endian.h sys/isa_defs.h \
+      machine/endian.h machine/param.h sys/machine.h sys/types.h \
+      fp.h float.h endian.h inttypes.h locale.h float.h stdint.h])
+    SECTION_FLAGS='-ffunction-sections -fdata-sections'
+    AC_SUBST(SECTION_FLAGS)
+    GLIBCXX_CHECK_LINKER_FEATURES
+    GLIBCXX_CHECK_COMPLEX_MATH_SUPPORT
+    GLIBCXX_CHECK_ICONV_SUPPORT
+
+    # For LFS.
+    AC_DEFINE(HAVE_INT64_T)
+
+    # For showmanyc_helper().
+    AC_CHECK_HEADERS(sys/ioctl.h sys/filio.h)
+    GLIBCXX_CHECK_POLL
+    GLIBCXX_CHECK_S_ISREG_OR_S_IFREG
+
+    # For xsputn_2().
+    AC_CHECK_HEADERS(sys/uio.h)
+    GLIBCXX_CHECK_WRITEV
+
+    GLIBCXX_CHECK_MATH_SUPPORT
+    GLIBCXX_CHECK_BUILTIN_MATH_SUPPORT
+    GLIBCXX_CHECK_COMPLEX_MATH_SUPPORT
+    GLIBCXX_CHECK_ICONV_SUPPORT
+    GLIBCXX_CHECK_STDLIB_SUPPORT
+    GLIBCXX_CHECK_S_ISREG_OR_S_IFREG
+    ;;
   *-solaris*)
     case "$target" in
       *-solaris2.8 | *-solaris2.9 | *-solaris2.10)
