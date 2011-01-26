Index: configure.ac
===================================================================
--- configure.ac	(revision 169303)
+++ configure.ac	(working copy)
@@ -190,6 +190,7 @@
 target_libraries="target-libgcc \
 		target-libiberty \
 		target-libgloss \
+		target-libunixlib \
 		target-newlib \
 		target-libgomp \
 		target-libstdc++-v3 \
@@ -1065,6 +1066,14 @@
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
@@ -1621,7 +1630,7 @@
 AC_SUBST(poststage1_ldflags)
 
 # Check for PPL
-ppllibs=" -lppl_c -lppl -lgmpxx"
+ppllibs=" -lppl_c -lppl -lpwl -lgmpxx"
 pplinc=
 
 AC_ARG_WITH(ppl,
@@ -1643,7 +1652,7 @@
   "" | yes)
     ;;
   *)
-    ppllibs="-L$with_ppl/lib -lppl_c -lppl -lgmpxx"
+    ppllibs="-L$with_ppl/lib -lppl_c -lppl -lpwl -lgmpxx"
     pplinc="-I$with_ppl/include $pplinc"
     ;;
 esac
@@ -1651,10 +1660,10 @@
   pplinc="-I$with_ppl_include $pplinc"
 fi
 if test "x$with_ppl_lib" != x; then
-  ppllibs="-L$with_ppl_lib -lppl_c -lppl -lgmpxx"
+  ppllibs="-L$with_ppl_lib -lppl_c -lppl -lpwl -lgmpxx"
 fi
 if test "x$with_ppl$with_ppl_include$with_ppl_lib" = x && test -d ${srcdir}/ppl; then
-  ppllibs='-L$$r/$(HOST_SUBDIR)/ppl/interfaces/C/'"$lt_cv_objdir"' -L$$r/$(HOST_SUBDIR)/ppl/src/'"$lt_cv_objdir"' -lppl_c -lppl -lgmpxx '
+  ppllibs='-L$$r/$(HOST_SUBDIR)/ppl/interfaces/C/'"$lt_cv_objdir"' -L$$r/$(HOST_SUBDIR)/ppl/src/'"$lt_cv_objdir"' -lppl_c -lppl -lpwl -lgmpxx '
   pplinc='-I$$r/$(HOST_SUBDIR)/ppl/src -I$$r/$(HOST_SUBDIR)/ppl/interfaces/C '
   enable_ppl_version_check=no
 fi
@@ -3073,6 +3082,10 @@
    ;;
   esac
   ;;
+
+ *" libunixlib "*)
+  FLAGS_FOR_TARGET=$FLAGS_FOR_TARGET' -B$$r/$(TARGET_SUBDIR)/libunixlib/ -B$$r/$(TARGET_SUBDIR)/libunixlib/.libs/ -isystem $$s/libunixlib/include'
+  ;;
 esac
 
 case "$target" in
