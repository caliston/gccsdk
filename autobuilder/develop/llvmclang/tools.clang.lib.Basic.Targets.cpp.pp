--- tools/clang/lib/Basic/Targets.cpp.orig	2014-08-08 23:59:37.000000000 +0100
+++ tools/clang/lib/Basic/Targets.cpp	2015-01-17 18:04:56.708103004 +0000
@@ -6012,6 +6012,27 @@
 };
 } // end anonymous namespace.
 
+namespace {
+template<typename Target>
+class RISCOSTargetInfo : public OSTargetInfo<Target> {
+protected:
+  void getOSDefines(const LangOptions &Opts, const llvm::Triple &Triple,
+		    MacroBuilder &Builder) const override {
+    Builder.defineMacro("__riscos__");
+    Builder.defineMacro("__riscos");
+    Builder.defineMacro("__ELF__");
+  }
+public:
+  RISCOSTargetInfo(const llvm::Triple &Triple) : OSTargetInfo<Target>(Triple) {
+    this->UserLabelPrefix = "";
+    // ptrdiff_t is defined as being of type long in GCC and libstdc++, but defaults
+    // to int here for an ARM target. We have to define it as long too to ensure
+    // functions that use ptrdiff_t as an argument type will have signatures that
+    // match.
+    this->PtrDiffType = TargetInfo::SignedLong;
+  }
+};
+} // end anonymous namespace.
 
 //===----------------------------------------------------------------------===//
 // Driver code
@@ -6056,6 +6077,8 @@
     }
 
   case llvm::Triple::arm:
+    if (os == llvm::Triple::RISCOS)
+      return new RISCOSTargetInfo<ARMleTargetInfo>(Triple);
   case llvm::Triple::thumb:
     if (Triple.isOSBinFormatMachO())
       return new DarwinARMTargetInfo(Triple);
