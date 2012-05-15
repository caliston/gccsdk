Index: libtool.m4
===================================================================
--- libtool.m4	(revision 187550)
+++ libtool.m4	(working copy)
@@ -1742,6 +1742,12 @@
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
@@ -2672,6 +2678,14 @@
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
@@ -3648,6 +3662,11 @@
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
@@ -3873,6 +3892,11 @@
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
@@ -3971,6 +3995,12 @@
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
@@ -4149,6 +4179,12 @@
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
@@ -5168,6 +5204,10 @@
       _LT_TAGVAR(hardcode_shlibpath_var, $1)=no
       ;;
 
+    *riscos)
+      _LT_TAGVAR(ld_shlibs, $1)=yes
+      ;;
+
     *)
       _LT_TAGVAR(ld_shlibs, $1)=no
       ;;
@@ -6395,6 +6435,10 @@
         _LT_TAGVAR(ld_shlibs, $1)=no
         ;;
 
+     *riscos)
+        _LT_TAGVAR(ld_shlibs, $1)=yes
+        ;;
+
       *)
         # FIXME: insert proper C++ library support
         _LT_TAGVAR(ld_shlibs, $1)=no
