Index: Makefile.def
===================================================================
--- Makefile.def	(revision 97921)
+++ Makefile.def	(working copy)
@@ -119,6 +119,7 @@
 target_modules = { module= libmudflap; lib_path=.libs; };
 target_modules = { module= libssp; lib_path=.libs; };
 target_modules = { module= newlib; };
+target_modules = { module= libunixlib; };
 target_modules = { module= libgfortran; };
 target_modules = { module= libobjc; };
 target_modules = { module= libtermcap; no_check=true;
@@ -469,6 +470,7 @@
 dependencies = { module=all-target-libobjc; on=all-target-libiberty; };
 dependencies = { module=all-target-libobjc; on=all-target-boehm-gc; };
 dependencies = { module=all-target-libstdc++-v3; on=all-target-libiberty; };
+dependencies = { module=configure-target-libiberty; on=all-target-libunixlib; };
 
 // Target libraries installed under gcc need to be installed before gcc
 dependencies = { module=install-target-libssp; on=install-gcc; };

