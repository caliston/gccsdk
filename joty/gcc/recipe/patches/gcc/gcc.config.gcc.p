Index: gcc/config.gcc
===================================================================
--- gcc/config.gcc	(revision 168558)
+++ gcc/config.gcc	(working copy)
@@ -874,6 +874,15 @@
 	tmake_file="arm/t-arm arm/t-arm-elf t-rtems arm/t-rtems"
 	tmake_file="${tmake_file} arm/t-arm-softfp soft-fp/t-softfp"
 	;;
+arm*-*-riscos)	# ARM RISC OS with ELF
+	tm_file="dbxelf.h elfos.h arm/riscos-elf.h arm/elf.h arm/aout.h arm/arm.h"
+	tmake_file="arm/t-arm arm/t-arm-riscos-elf"
+	tmake_file="${tmake_file} arm/t-arm-softfp soft-fp/t-softfp"
+	xm_file="arm/xm-riscos.h"
+	extra_options="${extra_options} arm/riscos.opt"
+	extra_objs="riscos.o"
+	extra_gcc_objs="riscos-gcc.o"
+	;;
 arm*-*-elf)
 	tm_file="dbxelf.h elfos.h newlib-stdint.h arm/unknown-elf.h arm/elf.h arm/aout.h arm/arm.h"
 	tmake_file="arm/t-arm arm/t-arm-elf"