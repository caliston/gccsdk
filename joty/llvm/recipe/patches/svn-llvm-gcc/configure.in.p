Index: configure.in
===================================================================
--- configure.in	(revision 107570)
+++ configure.in	(working copy)
@@ -25,6 +25,8 @@
 AC_CANONICAL_SYSTEM
 AC_ARG_PROGRAM
 
+m4_pattern_allow([^AS_FOR_TARGET$])dnl
+
 # Get 'install' or 'install-sh' and its variants.
 AC_PROG_INSTALL
 ACX_PROG_LN
@@ -144,6 +146,7 @@
 target_libraries="target-libiberty \
 		target-libgloss \
 		target-newlib \
+		target-libunixlib \
 		target-libstdc++-v3 \
 		target-libmudflap \
 		target-libssp \
@@ -230,7 +233,7 @@
 
 # Similarly, some are only suitable for cross toolchains.
 # Remove these if host=target.
-cross_only="target-libgloss target-newlib target-opcodes"
+cross_only="target-libgloss target-newlib target-libunixlib target-opcodes"
 
 case $is_cross_compiler in
   no) skipdirs="${skipdirs} ${cross_only}" ;;
@@ -2181,6 +2184,10 @@
    ;;
   esac
   ;;
+
+ *" libunixlib "*)
+  FLAGS_FOR_TARGET=$FLAGS_FOR_TARGET' -B$$r/$(TARGET_SUBDIR)/libunixlib/ -B$$r/$(TARGET_SUBDIR)/libunixlib/.libs/ -isystem $$s/libunixlib/include'
+  ;;
 esac
 case "$target" in
 *-mingw*)
