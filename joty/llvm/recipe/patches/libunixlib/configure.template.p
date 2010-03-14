Index: configure.template
===================================================================
--- configure.template	(revision 4513)
+++ configure.template	(working copy)
@@ -6,8 +6,7 @@
 
 # Need this to obtain the GCC_NO_EXECUTABLES line.
 sinclude(../config/no-executables.m4)
-# Need this to make sure we're using overruled AC_LIBTOOL_SYS_DYNAMIC_LINKER
-sinclude(./libtool.m4)
+sinclude(../libtool.m4)
 
 AC_PREREQ(2.59)
 AC_INIT([RISC OS UnixLib C Runtime Library], 5.0, [http://gccsdk.riscos.info/], [libunixlib])
