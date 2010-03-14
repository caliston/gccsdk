Index: gcc/Makefile.in
===================================================================
--- gcc/Makefile.in	(revision 97921)
+++ gcc/Makefile.in	(working copy)
@@ -472,6 +472,10 @@
 # Test to see whether <limits.h> exists in the system header files.
 LIMITS_H_TEST = [ -f $(SYSTEM_HEADER_DIR)/limits.h ]
 
+# Control whether to install our own version of limits.h
+# FIXME: hard disabled here, should be controled via the t-* file.
+INSTALL_LIMITS_H = false
+
 # Directory for prefix to system directories, for
 # each of $(system_prefix)/usr/include, $(system_prefix)/usr/lib, etc.
 TARGET_SYSTEM_ROOT = @TARGET_SYSTEM_ROOT@
@@ -3549,10 +3553,12 @@
 	  fi; \
 	done
 	rm -f include/limits.h
-	cp xlimits.h include/limits.h
+	if $(INSTALL_LIMITS_H) ; then \
+	  cp xlimits.h include/limits.h ; \
+	  chmod a+r include/limits.h ; \
+	fi
 	rm -f include/unwind.h
 	cp $(UNWIND_H) include/unwind.h
-	chmod a+r include/limits.h
 # Install the README
 	rm -f include/README
 	cp $(srcdir)/../fixincludes/README-fixinc include/README
@@ -4307,10 +4313,13 @@
 	  $(INSTALL_DATA) $$file \
 	    $(DESTDIR)$(itoolsdatadir)/include/$$realfile ; \
 	done
-	$(INSTALL_DATA) xlimits.h $(DESTDIR)$(itoolsdatadir)/include/limits.h
 	$(INSTALL_DATA) $(UNWIND_H) $(DESTDIR)$(itoolsdatadir)/include/unwind.h
-	$(INSTALL_DATA) $(srcdir)/gsyslimits.h \
-	  $(DESTDIR)$(itoolsdatadir)/gsyslimits.h
+	if $(INSTALL_LIMITS_H) ; then \
+	  $(INSTALL_DATA) xlimits.h \
+	    $(DESTDIR)$(itoolsdatadir)/include/limits.h ; \
+	  $(INSTALL_DATA) $(srcdir)/gsyslimits.h \
+	    $(DESTDIR)$(itoolsdatadir)/gsyslimits.h ; \
+	fi
 	$(INSTALL_DATA) macro_list $(DESTDIR)$(itoolsdatadir)/macro_list
 	if [ x$(STMP_FIXPROTO) != x ] ; then \
 	  $(INSTALL_SCRIPT) $(mkinstalldirs) \
