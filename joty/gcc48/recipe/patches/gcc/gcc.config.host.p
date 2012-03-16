Index: gcc/config.host
===================================================================
--- gcc/config.host	(revision 185475)
+++ gcc/config.host	(working copy)
@@ -185,6 +185,9 @@
 
 # Machine-specific settings.
 case ${host} in
+  arm*-*-riscos)	# ARM RISC OS with ELF
+    host_xm_file="${host_xmake_file} arm/xm-riscos.h"
+    ;;
   hppa1.0-*-hpux10* | hppa1.1-*-hpux10* | hppa2*-*-hpux10*)
     out_host_hook_obj=host-hpux.o
     host_xmake_file="${host_xmake_file} x-hpux"
