--- gcc/mklibgcc.in.orig	2006-09-10 09:13:12.000000000 +0200
+++ gcc/mklibgcc.in	2010-07-04 19:34:10.016901483 +0200
@@ -104,7 +104,8 @@ fi
 # Build lines.
 
 gcc_compile='$(GCC_FOR_TARGET) $(LIBGCC2_CFLAGS) $(INCLUDES)'
-gcc_s_compile="$gcc_compile -DSHARED"
+# arm-unknown-riscos needs -fPIC when creating shared libraries:
+gcc_s_compile="$gcc_compile -DSHARED -fPIC"
 make_compile='$(MAKE) GCC_FOR_TARGET="$(GCC_FOR_TARGET)" \
 	  AR_FOR_TARGET="$(AR_FOR_TARGET)" \
 	  AR_CREATE_FOR_TARGET="$(AR_CREATE_FOR_TARGET)" \
@@ -201,10 +202,19 @@ for ml in $MULTILIBS; do
   libunwind_a=
   libunwind_so=
 
+  # SCL configurations do not support any threading so fall back on single
+  # thread mode (by undefining HAVE_GTHR_DEFAULT, include gthr.h results in
+  # including gthr-single.h instead of gthr-posix.h).
+  if echo $flags | grep -q -- -mlibscl ; then
+    gcc_compile="$gcc_compile -UHAVE_GTHR_DEFAULT"
+  else
+    gcc_compile=`echo ${gcc_compile} | sed -e 's/ -UHAVE_GTHR_DEFAULT//'`
+  fi
+
   if [ "$LIBUNWIND" ]; then
     libunwind_a=$dir/libunwind.a
   fi
-  if [ "$SHLIB_LINK" ]; then
+  if [ -n "$SHLIB_LINK" -a -z "`echo $flags | grep -- "-mlibscl"`" ]; then
     libgcc_eh_a=$dir/libgcc_eh.a
     libgcc_s_so=$dir/libgcc_s${SHLIB_EXT}
     if [ "$LIBUNWIND" ]; then
@@ -869,7 +879,7 @@ for ml in $MULTILIBS; do
   echo '	chmod 644'  ${ldir}/libgcov.a
   echo '	$(RANLIB_FOR_TARGET)' ${ldir}/libgcov.a
 
-  if [ "$SHLIB_LINK" ]; then
+  if [ -n "$SHLIB_LINK" -a -z "`echo $flags | grep -- "-mlibscl"`" ]; then
     echo '	$(INSTALL_DATA)' ${dir}/libgcc_eh.a ${ldir}/
     echo '	chmod 644'  ${ldir}/libgcc_eh.a
     echo '	$(RANLIB_FOR_TARGET)' ${ldir}/libgcc_eh.a