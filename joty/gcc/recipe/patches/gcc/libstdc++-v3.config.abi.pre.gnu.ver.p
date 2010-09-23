Index: libstdc++-v3/config/abi/pre/gnu.ver
===================================================================
--- libstdc++-v3/config/abi/pre/gnu.ver	(revision 164571)
+++ libstdc++-v3/config/abi/pre/gnu.ver	(working copy)
@@ -784,6 +784,8 @@
 
   # DO NOT DELETE THIS LINE.  Port-specific symbols, if any, will be here.
 
+    som___got;
+
   local:
     *;
 };
