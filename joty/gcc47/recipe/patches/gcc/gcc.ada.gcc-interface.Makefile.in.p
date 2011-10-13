Index: gcc/ada/gcc-interface/Makefile.in
===================================================================
--- gcc/ada/gcc-interface/Makefile.in	(revision 179940)
+++ gcc/ada/gcc-interface/Makefile.in	(working copy)
@@ -275,7 +275,7 @@
 INCLUDES_FOR_SUBDIR = -iquote . -iquote .. -iquote ../.. -iquote $(fsrcdir)/ada \
 	-I$(fsrcdir)/../include
 
-ifeq ($(strip $(filter-out cygwin32% mingw32% pe,$(osys))),)
+ifeq ($(strip $(filter-out cygwin32% mingw32% pe riscos%,$(osys))),)
   # On Windows native the tconfig.h files used by C runtime files needs to have
   # the gcc source dir in its include dir list
   INCLUDES_FOR_SUBDIR = -iquote . -iquote .. -iquote ../.. -iquote $(fsrcdir)/ada \
@@ -1843,6 +1843,26 @@
   LIBRARY_VERSION := $(LIB_VERSION)
 endif
 
+ifeq ($(strip $(filter-out arm% riscos%,$(arch) $(osys))),)
+  LIBGNAT_TARGET_PAIRS = \
+  a-intnam.ads<a-intnam-riscos.ads \
+  s-inmaop.adb<s-inmaop-posix.adb \
+  s-intman.adb<s-intman-posix.adb \
+  s-auxdec.ads<s-auxdec-empty.ads \
+  s-auxdec.adb<s-auxdec-empty.adb \
+  s-osinte.adb<s-osinte-posix.adb \
+  s-osinte.ads<s-osinte-riscos.ads \
+  s-osprim.adb<s-osprim-posix.adb \
+  s-taprop.adb<s-taprop-riscos.adb \
+  s-taspri.ads<s-taspri-posix.ads \
+  s-tpopsp.adb<s-tpopsp-posix.adb \
+  g-soccon.ads<g-soccon-riscos.ads \
+  system.ads<system-riscos-arm.ads
+
+  # FIXME: GCCSDK: most probably needs updating !
+  EH_MECHANISM=-gcc
+endif
+
 ifeq ($(strip $(filter-out arm% linux-gnueabi,$(arch) $(osys)-$(word 4,$(targ)))),)
   LIBGNAT_TARGET_PAIRS = \
   a-intnam.ads<a-intnam-linux.ads \
