--- configure.in.orig	2006-11-21 18:48:36.000000000 +0100
+++ configure.in	2010-07-04 19:34:06.694401747 +0200
@@ -21,10 +21,27 @@
 sinclude(config/acx.m4)
 
 AC_INIT(move-if-change)
-AC_PREREQ(2.13)
+AC_PREREQ(2.59)
+
+# Find the build, host, and target systems.
+ACX_NONCANONICAL_BUILD
+ACX_NONCANONICAL_HOST
+ACX_NONCANONICAL_TARGET
+
+dnl Autoconf 2.5x and later will set a default program prefix if
+dnl --target was used, even if it was the same as --host.  Disable
+dnl that behavior.  This must be done before AC_CANONICAL_SYSTEM
+dnl to take effect.
+test "$host_noncanonical" = "$target_noncanonical" &&
+  test "$program_prefix$program_suffix$program_transform_name" = \
+    NONENONEs,x,x, &&
+  program_transform_name=s,y,y,
+
 AC_CANONICAL_SYSTEM
 AC_ARG_PROGRAM
 
+m4_pattern_allow([^AS_FOR_TARGET$])dnl
+
 # Get 'install' or 'install-sh' and its variants.
 AC_PROG_INSTALL
 ACX_PROG_LN
@@ -142,7 +159,8 @@ libgcj="target-libffi \
 # these libraries are built for the target environment, and are built after
 # the host libraries and the host tools (which may be a cross compiler)
 #
-target_libraries="target-libiberty \
+target_libraries="target-libunixlib \
+		target-libiberty \
 		target-libgloss \
 		target-newlib \
 		target-libstdc++-v3 \
@@ -817,6 +835,14 @@ case "${target}" in
     ;;
 esac
 
+case "${target}" in
+  arm-riscos*-* | arm-*-riscos)
+    ;;
+  *)
+    noconfigdirs="$noconfigdirs target-libunixlib"
+    ;;
+esac
+
 # If we aren't building newlib, then don't build libgloss, since libgloss
 # depends upon some newlib header files.
 case "${noconfigdirs}" in
@@ -1005,9 +1031,9 @@ if test "${build}" != "${host}" ; then
   # If we are doing a Canadian Cross, in which the host and build systems
   # are not the same, we set reasonable default values for the tools.
 
-  CC=${CC-${host_alias}-gcc}
+  CC=${CC-${host_noncanonical}-gcc}
   CFLAGS=${CFLAGS-"-g -O2"}
-  CXX=${CXX-${host_alias}-c++}
+  CXX=${CXX-${host_noncanonical}-c++}
   CXXFLAGS=${CXXFLAGS-"-g -O2"}
   CC_FOR_BUILD=${CC_FOR_BUILD-gcc}
   BUILD_PREFIX=${build_alias}-
@@ -1446,7 +1472,7 @@ if test x"${with_headers}" != x && test 
     "") x=${prefix} ;;
     *) x=${exec_prefix} ;;
     esac
-    copy_dirs="${copy_dirs} ${with_headers} $x/${target_alias}/sys-include"
+    copy_dirs="${copy_dirs} ${with_headers} $x/${target_noncanonical}/sys-include"
   fi
 fi
 
@@ -1466,7 +1492,7 @@ if test x"${with_libs}" != x && test x"$
     *) x=${exec_prefix} ;;
     esac
     for l in ${with_libs}; do
-      copy_dirs="$l $x/${target_alias}/lib ${copy_dirs}"
+      copy_dirs="$l $x/${target_noncanonical}/lib ${copy_dirs}"
     done
   fi
 fi
@@ -1614,7 +1640,7 @@ esac
 
 # Some systems (e.g., one of the i386-aix systems the gas testers are
 # using) don't handle "\$" correctly, so don't use it here.
-tooldir='${exec_prefix}'/${target_alias}
+tooldir='${exec_prefix}'/${target_noncanonical}
 build_tooldir=${tooldir}
 
 # Create a .gdbinit file which runs the one in srcdir
@@ -1881,40 +1907,86 @@ serialization_dependencies=serdep.tmp
 AC_SUBST_FILE(serialization_dependencies)
 
 # Base args.  Strip norecursion, cache-file, srcdir, host, build,
-# target and nonopt.  These are the ones we might not want to pass
-# down to subconfigures.  Also strip program-prefix, program-suffix,
-# and program-transform-name, so that we can pass down a consistent
-# program-transform-name.  If autoconf has put single quotes around
-# any of these arguments (because they contain shell metacharacters)
-# then this will fail; in practice this only happens for
-# --program-transform-name, so be sure to override --program-transform-name
-# at the end of the argument list.
-# These will be expanded by make, so quote '$'.
-cat <<\EOF_SED > conftestsed
-s/ --no[[^ ]]*/ /g
-s/ --c[[a-z-]]*[[= ]][[^ ]]*//g
-s/ --sr[[a-z-]]*[[= ]][[^ ]]*//g
-s/ --ho[[a-z-]]*[[= ]][[^ ]]*//g
-s/ --bu[[a-z-]]*[[= ]][[^ ]]*//g
-s/ --t[[a-z-]]*[[= ]][[^ ]]*//g
-s/ --program-[[pst]][[a-z-]]*[[= ]][[^ ]]*//g
-s/ -cache-file[[= ]][[^ ]]*//g
-s/ -srcdir[[= ]][[^ ]]*//g
-s/ -host[[= ]][[^ ]]*//g
-s/ -build[[= ]][[^ ]]*//g
-s/ -target[[= ]][[^ ]]*//g
-s/ -program-prefix[[= ]][[^ ]]*//g
-s/ -program-suffix[[= ]][[^ ]]*//g
-s/ -program-transform-name[[= ]][[^ ]]*//g
-s/ [[^' -][^ ]*] / /
-s/^ *//;s/ *$//
-s,\$,$$,g
-EOF_SED
-sed -f conftestsed <<EOF_SED > conftestsed.out
- ${ac_configure_args} 
-EOF_SED
-baseargs=`cat conftestsed.out`
-rm -f conftestsed conftestsed.out
+# target, nonopt, and variable assignments.  These are the ones we
+# might not want to pass down to subconfigures.  Also strip
+# program-prefix, program-suffix, and program-transform-name, so that
+# we can pass down a consistent program-transform-name.
+baseargs=
+keep_next=no
+skip_next=no
+eval "set -- $ac_configure_args"
+for ac_arg; do
+  if test X"$skip_next" = X"yes"; then
+    skip_next=no
+    continue
+  fi
+  if test X"$keep_next" = X"yes"; then
+    case $ac_arg in
+      *\'*)
+	ac_arg=`echo "$ac_arg" | sed "s/'/'\\\\\\\\''/g"` ;;
+    esac
+    baseargs="$baseargs '$ac_arg'"
+    keep_next=no
+    continue
+  fi
+
+  # Handle separated arguments.  Based on the logic generated by
+  # autoconf 2.59.
+  case $ac_arg in
+    *=* | --config-cache | -C | -disable-* | --disable-* \
+      | -enable-* | --enable-* | -gas | --g* | -nfp | --nf* \
+      | -q | -quiet | --q* | -silent | --sil* | -v | -verb* \
+      | -with-* | --with-* | -without-* | --without-* | --x)
+      separate_arg=no
+      ;;
+    -*)
+      separate_arg=yes
+      ;;
+    *)
+      separate_arg=no
+      ;;
+  esac
+
+  case "$ac_arg" in
+    --no*)
+      continue
+      ;;
+    --c* | \
+    --sr* | \
+    --ho* | \
+    --bu* | \
+    --t* | \
+    --program-* | \
+    -cache_file* | \
+    -srcdir* | \
+    -host* | \
+    -build* | \
+    -target* | \
+    -program-prefix* | \
+    -program-suffix* | \
+    -program-transform-name* )
+      skip_next=$separate_arg
+      continue
+      ;;
+    -*)
+      # An option.  Add it.
+      case $ac_arg in
+	*\'*)
+	  ac_arg=`echo "$ac_arg" | sed "s/'/'\\\\\\\\''/g"` ;;
+      esac
+      baseargs="$baseargs '$ac_arg'"
+      keep_next=$separate_arg
+      ;;
+    *)
+      # Either a variable assignment, or a nonopt (triplet).  Don't
+      # pass it down; let the Makefile handle this.
+      continue
+      ;;
+  esac
+done
+# Remove the initial space we just introduced and, as these will be
+# expanded by make, quote '$'.
+baseargs=`echo "x$baseargs" | sed -e 's/^x *//' -e 's,\\$,$$,g'`
 
 # Add in --program-transform-name, after --program-prefix and
 # --program-suffix have been applied to it.  Autoconf has already
@@ -1957,7 +2029,7 @@ target_configargs=${baseargs}
 # sorts of decisions they want to make on this basis.  Please consider
 # this option to be deprecated.  FIXME.
 if test x${is_cross_compiler} = xyes ; then
-  target_configargs="--with-cross-host=${host_alias} ${target_configargs}"
+  target_configargs="--with-cross-host=${host_noncanonical} ${target_configargs}"
 fi
 
 # Default to --enable-multilib.
@@ -2034,6 +2106,10 @@ case " $target_configdirs " in
    ;;
   esac
   ;;
+
+ *" libunixlib "*)
+  FLAGS_FOR_TARGET=$FLAGS_FOR_TARGET' -B$$r/$(TARGET_SUBDIR)/libunixlib/ -B$$r/$(TARGET_SUBDIR)/libunixlib/.libs/ -isystem $$s/libunixlib/include'
+  ;;
 esac
 
 # Allow the user to override the flags for
@@ -2134,7 +2210,7 @@ changequote(,)
     # For an installed makeinfo, we require it to be from texinfo 4.2 or
     # higher, else we use the "missing" dummy.
     if ${MAKEINFO} --version \
-       | egrep 'texinfo[^0-9]*([1-3][0-9]|4\.[2-9]|[5-9])' >/dev/null 2>&1; then
+       | egrep 'texinfo[^0-9]*(4\.([2-9]|[1-9][0-9])|[5-9]|[1-9][0-9])' >/dev/null 2>&1; then
       :
     else
       MAKEINFO="$MISSING makeinfo"
@@ -2217,7 +2293,7 @@ GCC_TARGET_TOOL(lipo, LIPO_FOR_TARGET, L
 GCC_TARGET_TOOL(nm, NM_FOR_TARGET, NM, [binutils/nm-new])
 GCC_TARGET_TOOL(objdump, OBJDUMP_FOR_TARGET, OBJDUMP, [binutils/objdump])
 GCC_TARGET_TOOL(ranlib, RANLIB_FOR_TARGET, RANLIB, [binutils/ranlib])
-GCC_TARGET_TOOL(strip, STRIP_FOR_TARGET, STRIP, [binutils/strip])
+GCC_TARGET_TOOL(strip, STRIP_FOR_TARGET, STRIP, [binutils/strip-new])
 GCC_TARGET_TOOL(windres, WINDRES_FOR_TARGET, WINDRES, [binutils/windres])
 
 AC_SUBST(FLAGS_FOR_TARGET)