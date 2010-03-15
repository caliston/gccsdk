Index: tools/clang/tools/driver/driver.cpp
===================================================================
--- tools/clang/tools/driver/driver.cpp	(revision 98515)
+++ tools/clang/tools/driver/driver.cpp	(working copy)
@@ -199,7 +199,7 @@
   const bool IsProduction = false;
 #endif
   Driver TheDriver(Path.getBasename(), Path.getDirname(),
-                   llvm::sys::getHostTriple(),
+                   "armv4-unknown-eabi" /* llvm::sys::getHostTriple() */,
                    "a.out", IsProduction, Diags);
 
   // Check for ".*++" or ".*++-[^-]*" to determine if we are a C++
