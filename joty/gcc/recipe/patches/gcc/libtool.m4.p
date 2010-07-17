Index: libtool.m4
===================================================================
--- libtool.m4	(revision 162269)
+++ libtool.m4	(working copy)
@@ -1735,6 +1735,12 @@
     ])
     ;;
 
+  *riscos)
+    lt_cv_dlopen="dlopen"
+    lt_cv_dlopen_libs="-ldl"
+    lt_cv_dlopen_self=yes
+   ;;
+
   *)
     AC_CHECK_FUNC([shl_load],
 	  [lt_cv_dlopen="shl_load"],
@@ -2669,6 +2675,14 @@
   shlibpath_var=LD_LIBRARY_PATH
   ;;
 
+*riscos)
+  version_type=linux
+  library_names_spec='${libname}$versuffix.so ${libname}.so$major $libname.so'
+  soname_spec='${libname}.so$major'
+  dynamic_linker='RISC OS ld-riscos.so'
+  lt_cv_dlopen="dlopen"
+  ;;
+
 *)
   dynamic_linker=no
   ;;
@@ -3645,6 +3659,11 @@
       # it will coredump.
       _LT_TAGVAR(lt_prog_compiler_pic, $1)='-fPIC -shared'
       ;;
+    *riscos)
+      _LT_TAGVAR(lt_prog_compiler_pic, $1)='-fPIC'
+      _LT_TAGVAR(lt_prog_compiler_static, $1)='-static'
+      _LT_TAGVAR(lt_prog_compiler_wl, $1)='-Wl,'
+      ;;
     *)
       _LT_TAGVAR(lt_prog_compiler_pic, $1)='-fPIC'
       ;;
@@ -3870,6 +3889,11 @@
 	;;
       vxworks*)
 	;;
+      *riscos)
+        _LT_TAGVAR(lt_prog_compiler_pic, $1)='-fPIC'
+        _LT_TAGVAR(lt_prog_compiler_static, $1)='-static'
+        _LT_TAGVAR(lt_prog_compiler_wl, $1)='-Wl,'
+        ;;
       *)
 	_LT_TAGVAR(lt_prog_compiler_can_build_shared, $1)=no
 	;;
@@ -3968,6 +3992,12 @@
       fi
       ;;
 
+    *riscos)
+      _LT_TAGVAR(lt_prog_compiler_pic, $1)='-fPIC'
+      _LT_TAGVAR(lt_prog_compiler_static, $1)='-static'
+      _LT_TAGVAR(lt_prog_compiler_wl, $1)='-Wl,'
+      ;;
+
     *)
       _LT_TAGVAR(lt_prog_compiler_pic, $1)='-fPIC'
       ;;
@@ -4146,6 +4176,12 @@
       _LT_TAGVAR(lt_prog_compiler_static, $1)='-Bstatic'
       ;;
 
+    *riscos)
+      _LT_TAGVAR(lt_prog_compiler_pic, $1)='-fPIC'
+      _LT_TAGVAR(lt_prog_compiler_static, $1)='-static'
+      _LT_TAGVAR(lt_prog_compiler_wl, $1)='-Wl,'
+      ;;
+
     *)
       _LT_TAGVAR(lt_prog_compiler_can_build_shared, $1)=no
       ;;
@@ -5169,6 +5205,10 @@
       _LT_TAGVAR(hardcode_shlibpath_var, $1)=no
       ;;
 
+    *riscos)
+      _LT_TAGVAR(ld_shlibs, $1)=yes
+      ;;
+
     *)
       _LT_TAGVAR(ld_shlibs, $1)=no
       ;;
@@ -6396,6 +6436,10 @@
         _LT_TAGVAR(ld_shlibs, $1)=no
         ;;
 
+     *riscos)
+        _LT_TAGVAR(ld_shlibs, $1)=yes
+        ;;
+
       *)
         # FIXME: insert proper C++ library support
         _LT_TAGVAR(ld_shlibs, $1)=no
