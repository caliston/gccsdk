Index: libstdc++-v3/config/abi/pre/gnu.ver
===================================================================
--- libstdc++-v3/config/abi/pre/gnu.ver	(revision 161061)
+++ libstdc++-v3/config/abi/pre/gnu.ver	(working copy)
@@ -776,6 +776,8 @@
 
   # DO NOT DELETE THIS LINE.  Port-specific symbols, if any, will be here.
 
+    som___got;
+
   local:
     *;
 };
