Index: gcc/config/arm/lib1funcs.asm
===================================================================
--- gcc/config/arm/lib1funcs.asm	(revision 168231)
+++ gcc/config/arm/lib1funcs.asm	(working copy)
@@ -401,6 +401,20 @@
 
 /* Function start macros.  Variants for ARM and Thumb.  */
 
+#ifdef __riscos__
+
+/* Macro for embedding function names in code, just before
+ the function prologue (taken from UnixLib).  */
+.macro EMBED_NAME name
+0:
+	.asciz	"\name"
+	.align
+1:
+	.word	0xff000000 + (1b - 0b)
+.endm
+
+#endif
+
 #ifdef __thumb__
 #define THUMB_FUNC .thumb_func
 #define THUMB_CODE .force_thumb
@@ -423,6 +437,9 @@
 	THUMB_CODE
 	THUMB_FUNC
 	THUMB_SYNTAX
+#ifdef __riscos__
+	EMBED_NAME __\name
+#endif
 SYM (__\name):
 .endm
 
@@ -470,6 +487,9 @@
 	TYPE (__\name)
 	.align 0
 	.arm
+#ifdef __riscos__
+	EMBED_NAME __\name
+#endif
 SYM (__\name):
 .endm
 #define EQUIV .set
