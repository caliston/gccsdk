Index: gmon/gmon-start.c
===================================================================
--- gmon/gmon-start.c	(revision 4658)
+++ gmon/gmon-start.c	(working copy)
@@ -26,10 +26,10 @@
    as the external functions since we want the addresses of those
    labels. Taking the address of a function may have different
    meanings on different platforms. */
-extern void __text_start;
+extern void _start;
 extern void etext;
 
-#define TEXT_START &__text_start
+#define TEXT_START &_start
 
 /* In ELF and COFF, we cannot use the normal constructor mechanism to call
    __gmon_start__ because gcrt1.o appears before crtbegin.o in the link.
