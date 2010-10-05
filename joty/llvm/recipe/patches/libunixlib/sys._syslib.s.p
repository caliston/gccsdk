Index: sys/_syslib.s
===================================================================
--- sys/_syslib.s	(revision 4830)
+++ sys/_syslib.s	(working copy)
@@ -1466,9 +1466,9 @@
 	.word	0			@ rwlomem		offset = 16
 	.word	0			@ rwbase		offset = 20
 #else
-	.word	Image$$RO$$Base		@ robase		offset = 12
-	.word	Image$$RW$$Limit	@ rwlomem		offset = 16
-	.word	Image$$RW$$Base		@ rwbase		offset = 20
+	.word	__executable_start	@ robase (Image$$RO$$Base) offset = 12
+	.word	__end__			@ rwlomem (Image$$RW$$Limit) offset = 16
+	.word	__data_start		@ rwbase (Image$$RW$$Base) offset = 20
 #endif
 	.word	0			@ rwbreak		offset = 24
 	.word	0			@ stack_limit		offset = 28
