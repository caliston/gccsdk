Index: gcc/config.host
===================================================================
--- gcc/config.host	(revision 185264)
+++ gcc/config.host	(working copy)
@@ -201,6 +201,9 @@
     prefix=/gnu
     local_prefix=/gnu/local
     ;;
+  arm*-*-riscos)	# ARM RISC OS with ELF
+    host_xm_file="arm/xm-riscos.h"
+    ;;
   hppa1.0-*-hpux10* | hppa1.1-*-hpux10* | hppa2*-*-hpux10*)
     out_host_hook_obj=host-hpux.o
     host_xmake_file="${host_xmake_file} x-hpux"
