Index: libstdc++-v3/src/Makefile.am
===================================================================
--- libstdc++-v3/src/Makefile.am	(revision 187211)
+++ libstdc++-v3/src/Makefile.am	(working copy)
@@ -63,13 +63,11 @@
 
 libstdc___la_LIBADD = \
 	$(GLIBCXX_LIBS) \
-	$(top_builddir)/libsupc++/libsupc++convenience.la \
 	$(top_builddir)/src/c++98/libc++98convenience.la \
 	$(top_builddir)/src/c++11/libc++11convenience.la
 
 libstdc___la_DEPENDENCIES = \
 	${version_dep} \
-	$(top_builddir)/libsupc++/libsupc++convenience.la \
 	$(top_builddir)/src/c++98/libc++98convenience.la \
 	$(top_builddir)/src/c++11/libc++11convenience.la
 
@@ -164,6 +162,17 @@
 	$(OPT_LDFLAGS) $(SECTION_LDFLAGS) $(AM_CXXFLAGS) $(LTLDFLAGS) -o $@
 
 
+std_HEADERS = \
+	../libsupc++/cxxabi.h ../libsupc++/exception \
+	../libsupc++/initializer_list ../libsupc++/new \
+	../libsupc++/typeinfo 
+
+bits_HEADERS = \
+	../libsupc++/cxxabi_forced.h ../libsupc++/hash_bytes.h \
+	../libsupc++/exception_defines.h ../libsupc++/exception_ptr.h ../libsupc++/nested_exception.h 
+
+headers = $(std_HEADERS) $(bits_HEADERS)
+
 # Symbol versioning for shared libraries.
 if ENABLE_SYMVERS
 libstdc++-symbols.ver:  ${glibcxx_srcdir}/$(SYMVER_FILE) \
@@ -302,3 +311,43 @@
 install-debug: build-debug
 	(cd ${debugdir} && $(MAKE) CXXFLAGS='$(DEBUG_FLAGS)' \
 	toolexeclibdir=$(glibcxx_toolexeclibdir)/debug install) ;
+
+# Install notes
+# We have to have rules modified from the default to counteract SUN make
+# prepending each of $(*_HEADERS) with VPATH below.
+stddir = $(gxx_include_dir)
+bitsdir = $(gxx_include_dir)/bits
+
+install-stdHEADERS: $(std_HEADERS)
+	@$(NORMAL_INSTALL)
+	$(mkinstalldirs) $(DESTDIR)$(stddir)
+	@list='$(std_HEADERS)'; for p in $$list; do \
+	  q=`echo $$p | sed -e 's,.*/,,'`; \
+	  if test -f "$$p"; then d= ; else d="$(srcdir)/"; fi; \
+	  echo " $(INSTALL_DATA) $$d$$p $(DESTDIR)$(stddir)/$$q"; \
+	  $(INSTALL_DATA) $$d$$p $(DESTDIR)$(stddir)/$$q; \
+	done
+
+install-bitsHEADERS: $(bits_HEADERS)
+	@$(NORMAL_INSTALL)
+	$(mkinstalldirs) $(DESTDIR)$(bitsdir)
+	@list='$(bits_HEADERS)'; for p in $$list; do \
+	  q=`echo $$p | sed -e 's,.*/,,'`; \
+	  if test -f "$$p"; then d= ; else d="$(srcdir)/"; fi; \
+	  echo " $(INSTALL_DATA) $$d$$p $(DESTDIR)$(bitsdir)/$$q"; \
+	  $(INSTALL_DATA) $$d$$p $(DESTDIR)$(bitsdir)/$$q; \
+	done
+
+uninstall-stdHEADERS:
+	@$(NORMAL_UNINSTALL)
+	list='$(std_HEADERS)'; for p in $$list; do \
+	  q=`echo $$p | sed -e 's,.*/,,'`; \
+	  rm -f $(DESTDIR)$(stddir)/$$q; \
+	done
+
+uninstall-bitsHEADERS:
+	@$(NORMAL_UNINSTALL)
+	list='$(bits_HEADERS)'; for p in $$list; do \
+	  q=`echo $$p | sed -e 's,.*/,,'`; \
+	  rm -f $(DESTDIR)$(bitsdir)/$$q; \
+	done
