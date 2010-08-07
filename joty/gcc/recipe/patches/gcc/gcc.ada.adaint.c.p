Index: gcc/ada/adaint.c
===================================================================
--- gcc/ada/adaint.c	(revision 162881)
+++ gcc/ada/adaint.c	(working copy)
@@ -75,6 +75,10 @@
 #include "version.h"
 #endif
 
+#include <string.h>
+#include <stdlib.h>
+#include <unistd.h>
+
 #if defined (__MINGW32__)
 
 #if defined (RTX)
