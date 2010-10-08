Index: Makefile.def
===================================================================
--- Makefile.def	(revision 165069)
+++ Makefile.def	(working copy)
@@ -153,6 +153,7 @@
 		   raw_cxx=true; };
 target_modules = { module= libmudflap; lib_path=.libs; };
 target_modules = { module= libssp; lib_path=.libs; };
+target_modules = { module= libunixlib; lib_path=.libs; };
 target_modules = { module= newlib; };
 target_modules = { module= libgcc; bootstrap=true; no_check=true; };
 target_modules = { module= libgfortran; };
@@ -525,6 +526,7 @@
 // on libgcc and newlib/libgloss.
 lang_env_dependencies = { module=gperf; cxx=true; };
 lang_env_dependencies = { module=libjava; cxx=true; };
+lang_env_dependencies = { module=libunixlib; no_c=true; };
 lang_env_dependencies = { module=newlib; no_c=true; };
 lang_env_dependencies = { module=libgloss; no_c=true; };
 lang_env_dependencies = { module=libgcc; no_gcc=true; no_c=true; };
@@ -569,6 +571,9 @@
 dependencies = { module=all-target-winsup; on=all-target-libtermcap; };
 dependencies = { module=configure-target-libiberty; on=all-binutils; };
 dependencies = { module=configure-target-libiberty; on=all-ld; };
+dependencies = { module=configure-target-libiberty; on=all-target-libunixlib; };
+dependencies = { module=configure-target-libunixlib; on=all-binutils; };
+dependencies = { module=configure-target-libunixlib; on=all-ld; };
 dependencies = { module=configure-target-newlib; on=all-binutils; };
 dependencies = { module=configure-target-newlib; on=all-ld; };
 
