Index: libstdc++-v3/src/c++98/Makefile.am
===================================================================
--- libstdc++-v3/src/c++98/Makefile.am	(revision 183850)
+++ libstdc++-v3/src/c++98/Makefile.am	(working copy)
@@ -116,6 +116,58 @@
 inst_sources =
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
+	eh_tm.cc \
+	eh_type.cc \
+	eh_unex_handler.cc \
+	enum_type_info.cc \
+	function_type_info.cc \
+	fundamental_type_info.cc \
+	guard.cc \
+	guard_error.cc \
+	hash_bytes.cc \
+	nested_exception.cc \
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
 # Sources present in the src directory, always present.
 sources = \
 	bitmap_allocator.cc \
@@ -150,8 +202,10 @@
 	streambuf.cc \
 	valarray.cc \
 	${host_sources} \
-	${host_sources_extra}
+	${host_sources_extra} \
+	${supc_sources}
 
+vpath % $(top_srcdir)/libsupc++
 vpath % $(top_srcdir)/src/c++98
 vpath % $(top_srcdir)
 
@@ -214,6 +268,32 @@
 AM_MAKEFLAGS = \
 	"gxx_include_dir=$(gxx_include_dir)"
 
+# Use special rules for pulling things out of libiberty.  These
+# objects should be compiled with the "C" compiler, not the C++
+# compiler, and also should not use the C++ includes.
+C_INCLUDES = -I.. -I$(toplevel_srcdir)/libiberty -I$(toplevel_srcdir)/include
+C_COMPILE = \
+	$(CC) $(DEFS) $(C_INCLUDES) \
+	$(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
+ 
+# LTCOMPILE is copied from LTCXXCOMPILE below.
+LTCOMPILE = $(LIBTOOL) --tag CC $(LIBTOOLFLAGS) --mode=compile \
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
+nested_exception.lo: nested_exception.cc
+	$(LTCXXCOMPILE) -std=gnu++0x -c $<
+nested_exception.o: nested_exception.cc
+	$(CXXCOMPILE) -std=gnu++0x -c $<
+
 # Libtool notes
 
 # 1) Need to explicitly set LTCXXCOMPILE so that AM_CXXFLAGS is
