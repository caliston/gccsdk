--- include/elf/common.h.orig	2012-03-21 20:15:16.000000000 +0000
+++ include/elf/common.h	2012-03-21 20:15:06.000000000 +0000
@@ -723,6 +723,9 @@
 #define DT_LOPROC	0x70000000
 #define DT_HIPROC	0x7fffffff
 
+#define DT_RISCOS_PIC	DT_LOOS
+#define DT_RISCOS_ABI_VERSION DT_LOOS+1
+
 /* The next 2 dynamic tag ranges, integer value range (DT_VALRNGLO to
    DT_VALRNGHI) and virtual address range (DT_ADDRRNGLO to DT_ADDRRNGHI),
    are used on Solaris.  We support them everywhere.  Note these values
