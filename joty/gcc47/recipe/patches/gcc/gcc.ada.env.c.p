Index: gcc/ada/env.c
===================================================================
--- gcc/ada/env.c	(revision 176214)
+++ gcc/ada/env.c	(working copy)
@@ -69,6 +69,9 @@
 #include "system.h"
 #endif /* IN_RTS */
 
+#include <stdio.h>
+#include <stdlib.h>
+
 #if defined (__APPLE__)
 #include <crt_externs.h>
 #endif
