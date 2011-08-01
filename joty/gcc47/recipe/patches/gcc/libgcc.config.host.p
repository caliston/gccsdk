Index: libgcc/config.host
===================================================================
--- libgcc/config.host	(revision 177068)
+++ libgcc/config.host	(working copy)
@@ -271,7 +271,7 @@
 	;;
 arm*-*-ecos-elf)
 	;;
-arm*-*-eabi* | arm*-*-symbianelf* )
+arm*-*-eabi* | arm*-*-symbianelf* | arm*-*-riscos)
 	tmake_file="${tmake_file} t-fixedpoint-gnu-prefix"
 	;;
 arm*-*-rtems*)
