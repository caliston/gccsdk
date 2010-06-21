Index: libiberty/configure.ac
===================================================================
--- libiberty/configure.ac	(revision 161055)
+++ libiberty/configure.ac	(working copy)
@@ -176,6 +176,15 @@
   enable_shared=no
 fi
 
+case "${host}" in
+  arm-unknown-riscos)
+    # Don't build a shared library for SCL:
+    if [[ -n "`echo $CC | grep -- -mlibscl`" ]]; then
+      enable_shared=no
+    fi
+    ;;
+esac
+
 frag=
 case "${host}" in
   rs6000-ibm-aix3.1 | rs6000-ibm-aix)
