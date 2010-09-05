Index: tools/clang/tools/driver/driver.cpp
===================================================================
--- tools/clang/tools/driver/driver.cpp	(revision 113069)
+++ tools/clang/tools/driver/driver.cpp	(working copy)
@@ -301,7 +301,7 @@
   const bool IsProduction = false;
   const bool CXXIsProduction = false;
 #endif
-  Driver TheDriver(Path.str(), llvm::sys::getHostTriple(),
+  Driver TheDriver(Path.str(), "armv4-unknown-eabi" /* llvm::sys::getHostTriple() */,
                    "a.out", IsProduction, CXXIsProduction,
                    Diags);
 
