Index: libgcc/config.host
===================================================================
--- libgcc/config.host	(revision 177545)
+++ libgcc/config.host	(working copy)
@@ -300,10 +300,10 @@
 arm*-*-ecos-elf)
 	tmake_file="$tmake_file t-softfp-sfdf t-softfp-excl arm/t-softfp t-softfp"
 	;;
-arm*-*-eabi* | arm*-*-symbianelf* )
+arm*-*-eabi* | arm*-*-symbianelf* | arm*-*-riscos)
 	tmake_file="${tmake_file} t-fixedpoint-gnu-prefix"
 	case ${host} in
-	arm*-*-eabi*)
+	arm*-*-eabi* | arm*-*-riscos)
 	  tmake_file="${tmake_file} arm/t-bpabi"
 	  ;;
 	arm*-*-symbianelf*)
