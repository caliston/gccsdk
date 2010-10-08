Index: configure.ac
===================================================================
--- configure.ac	(revision 165147)
+++ configure.ac	(working copy)
@@ -189,6 +189,7 @@
 target_libraries="target-libgcc \
 		target-libiberty \
 		target-libgloss \
+		target-libunixlib \
 		target-newlib \
 		target-libgomp \
 		target-libstdc++-v3 \
@@ -993,6 +994,14 @@
     ;;
 esac
 
+case "${target}" in
+  arm-riscos*-* | arm-*-riscos)
+    ;;
+  *)
+    noconfigdirs="$noconfigdirs target-libunixlib"
+    ;;
+esac
+
 # If we aren't building newlib, then don't build libgloss, since libgloss
 # depends upon some newlib header files.
 case "${noconfigdirs}" in
@@ -3102,6 +3111,10 @@
    ;;
   esac
   ;;
+
+ *" libunixlib "*)
+  FLAGS_FOR_TARGET=$FLAGS_FOR_TARGET' -B$$r/$(TARGET_SUBDIR)/libunixlib/ -B$$r/$(TARGET_SUBDIR)/libunixlib/.libs/ -isystem $$s/libunixlib/include'
+  ;;
 esac
 
 case "$target" in
@@ -3336,7 +3349,7 @@
 GCC_TARGET_TOOL(nm, NM_FOR_TARGET, NM, [binutils/nm-new])
 GCC_TARGET_TOOL(objdump, OBJDUMP_FOR_TARGET, OBJDUMP, [binutils/objdump])
 GCC_TARGET_TOOL(ranlib, RANLIB_FOR_TARGET, RANLIB, [binutils/ranlib])
-GCC_TARGET_TOOL(strip, STRIP_FOR_TARGET, STRIP, [binutils/strip])
+GCC_TARGET_TOOL(strip, STRIP_FOR_TARGET, STRIP, [binutils/strip-new])
 GCC_TARGET_TOOL(windres, WINDRES_FOR_TARGET, WINDRES, [binutils/windres])
 GCC_TARGET_TOOL(windmc, WINDMC_FOR_TARGET, WINDMC, [binutils/windmc])
 
