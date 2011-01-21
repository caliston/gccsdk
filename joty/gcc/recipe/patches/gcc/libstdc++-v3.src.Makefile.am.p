Index: libstdc++-v3/src/Makefile.am
===================================================================
--- libstdc++-v3/src/Makefile.am	(revision 168231)
+++ libstdc++-v3/src/Makefile.am	(working copy)
@@ -27,6 +27,22 @@
 # Cross compiler support.
 toolexeclib_LTLIBRARIES = libstdc++.la
 
+headers = \
+	../libsupc++/exception \
+	../libsupc++/new \
+	../libsupc++/typeinfo \
+	../libsupc++/cxxabi.h \
+	../libsupc++/cxxabi-forced.h \
+	../libsupc++/exception_defines.h \
+	../libsupc++/initializer_list \
+	../libsupc++/exception_ptr.h \
+	../libsupc++/nested_exception.h
+
+if GLIBCXX_HOSTED
+  c_sources = \
+	cp-demangle.c 
+endif
+
 # Symbol versioning for shared libraries.
 if ENABLE_SYMVERS
 libstdc++-symbols.ver:  ${glibcxx_srcdir}/$(SYMVER_FILE) \
@@ -159,6 +175,55 @@
 ldbl_compat_sources =
 endif
 
+# Sources present in the libsupc++ directory.
+supc_sources = \
+	array_type_info.cc \
+	atexit_arm.cc \
+	bad_alloc.cc \
+	bad_cast.cc \
+	bad_typeid.cc \
+	class_type_info.cc \
+	del_op.cc \
+	del_opnt.cc \
+	del_opv.cc \
+	del_opvnt.cc \
+	dyncast.cc \
+	eh_alloc.cc \
+	eh_arm.cc \
+	eh_aux_runtime.cc \
+	eh_call.cc \
+	eh_catch.cc \
+	eh_exception.cc \
+	eh_globals.cc \
+	eh_personality.cc \
+	eh_ptr.cc \
+	eh_term_handler.cc \
+	eh_terminate.cc \
+	eh_throw.cc \
+	eh_type.cc \
+	eh_unex_handler.cc \
+	enum_type_info.cc \
+	function_type_info.cc \
+	fundamental_type_info.cc \
+	guard.cc \
+	hash_bytes.cc \
+	new_handler.cc \
+	new_op.cc \
+	new_opnt.cc \
+	new_opv.cc \
+	new_opvnt.cc \
+	pbase_type_info.cc \
+	pmem_type_info.cc \
+	pointer_type_info.cc \
+	pure.cc \
+	si_class_type_info.cc \
+	tinfo.cc \
+	tinfo2.cc \
+	vec.cc \
+	vmi_class_type_info.cc \
+	vterminate.cc \
+	$(c_sources)
+
 # Sources present in the src directory.
 sources = \
 	atomic.cc \
@@ -220,26 +285,29 @@
 	thread.cc \
 	future.cc \
 	${host_sources} \
-	${host_sources_extra} 
+	${host_sources_extra} \
+	${supc_sources}
 
-vpath % $(top_srcdir)/src
-vpath % $(top_srcdir)
+VPATH = $(top_srcdir)/src:$(top_srcdir)/libsupc++
+#vpath % $(top_srcdir)/src
+#vpath % $(top_srcdir)
 
 libstdc___la_SOURCES = $(sources)
 
 libstdc___la_LIBADD = \
-	$(GLIBCXX_LIBS) \
-	$(top_builddir)/libsupc++/libsupc++convenience.la
+	$(GLIBCXX_LIBS)
 
 libstdc___la_DEPENDENCIES = \
-	${version_dep} \
-	$(top_builddir)/libsupc++/libsupc++convenience.la
+	${version_dep}
 
 libstdc___la_LDFLAGS = \
 	-version-info $(libtool_VERSION) ${version_arg} -lm 
 
 libstdc___la_LINK = $(CXXLINK) $(libstdc___la_LDFLAGS)
 
+glibcxxinstalldir = $(gxx_include_dir)
+glibcxxinstall_HEADERS = $(headers)
+
 # Use special rules for the deprecated source files so that they find
 # deprecated include files.
 GLIBCXX_INCLUDE_DIR=$(glibcxx_builddir)/include
@@ -374,7 +442,27 @@
 	$(OPTIMIZE_CXXFLAGS) \
 	$(CONFIG_CXXFLAGS)
 
+# Use special rules for pulling things out of libiberty.  These
+# objects should be compiled with the "C" compiler, not the C++
+# compiler, and also should not use the C++ includes.
+C_INCLUDES = -I.. -I$(toplevel_srcdir)/libiberty -I$(toplevel_srcdir)/include
+C_COMPILE = \
+	$(CC) $(DEFS) $(C_INCLUDES) \
+	$(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
 
+# LTCOMPILE is copied from LTCXXCOMPILE below.
+LTCOMPILE = $(LIBTOOL) --tag CC --tag disable-shared $(LIBTOOLFLAGS) --mode=compile \
+	    $(CC) $(DEFS) $(C_INCLUDES) $(LIBSUPCXX_PICFLAGS) \
+            $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
+
+cp-demangle.c:
+	rm -f $@
+	$(LN_S) $(toplevel_srcdir)/libiberty/cp-demangle.c $@
+cp-demangle.lo: cp-demangle.c
+	$(LTCOMPILE) -DIN_GLIBCPP_V3 -Wno-error -c $<
+cp-demangle.o: cp-demangle.c
+	$(C_COMPILE) -DIN_GLIBCPP_V3 -Wno-error -c $<
+
 # libstdc++ libtool notes
 
 # 1) Need to explicitly set LTCXXCOMPILE so that AM_CXXFLAGS is
@@ -394,7 +482,7 @@
 # CXXLINK, just after $(LIBTOOL), so that libtool doesn't have to
 # attempt to infer which configuration to use
 LTCXXCOMPILE = $(LIBTOOL) --tag CXX $(AM_LIBTOOLFLAGS) $(LIBTOOLFLAGS) --mode=compile \
-	       $(CXX) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CXXFLAGS) $(CXXFLAGS)
+	       $(CXX) $(INCLUDES) $(TOPLEVEL_INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CXXFLAGS) $(CXXFLAGS)
 
 LTLDFLAGS = $(shell $(SHELL) $(top_srcdir)/../libtool-ldflags $(LDFLAGS))
 
