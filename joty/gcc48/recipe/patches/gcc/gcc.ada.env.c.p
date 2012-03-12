Index: gcc/ada/env.c
===================================================================
--- gcc/ada/env.c	(revision 185264)
+++ gcc/ada/env.c	(working copy)
@@ -76,6 +76,9 @@
 #include "system.h"
 #endif /* IN_RTS */
 
+#include <stdio.h>
+#include <stdlib.h>
+
 #if defined (__APPLE__)
 #include <crt_externs.h>
 #endif
