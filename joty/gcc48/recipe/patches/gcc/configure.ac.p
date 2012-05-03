Index: configure.ac
===================================================================
--- configure.ac	(revision 187115)
+++ configure.ac	(working copy)
@@ -152,6 +152,7 @@
 # Note that libiberty is not a target library.
 target_libraries="target-libgcc \
 		target-libgloss \
+		target-libunixlib \
 		target-newlib \
 		target-libgomp \
 		target-libatomic \
@@ -1063,6 +1064,14 @@
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
@@ -2886,6 +2895,10 @@
    ;;
   esac
   ;;
+
+ *" libunixlib "*)
+  FLAGS_FOR_TARGET=$FLAGS_FOR_TARGET' -B$$r/$(TARGET_SUBDIR)/libunixlib/ -B$$r/$(TARGET_SUBDIR)/libunixlib/.libs/ -isystem $$s/libunixlib/include'
+  ;;
 esac
 
 case "$target" in
