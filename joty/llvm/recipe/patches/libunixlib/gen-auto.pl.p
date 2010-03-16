Index: gen-auto.pl
===================================================================
--- gen-auto.pl	(revision 4508)
+++ gen-auto.pl	(working copy)
@@ -180,10 +180,9 @@
 output_make_var ("nobase_noinst_HEADERS", \@noinst_headers, "incl-local");
 print MAKE "\n";
 
-print MAKE "libm_la_SOURCES = libm-support/libm.c\n\n";
-print MAKE "toolexeclib_LTLIBRARIES = libunixlib.la libm.la\n";
+print MAKE "toolexeclib_LTLIBRARIES = libc.la libg.la libm.la\n";
 
-print MAKE "libunixlib_la_SOURCES = ";
+print MAKE "libc_la_SOURCES = ";
 my $x = 0;
 foreach $m (@makevars) {
     # Don't include the crt sources and SUL module in the library make list.
@@ -196,11 +195,17 @@
 	$x = 0;
     }
 }
-
 print MAKE "\n\n";
 
-print MAKE "libunixlib_la_LDFLAGS = -Wc,-lgcc_s -Wc,-nostdlib -version-info 5:0:0 -Wl,--version-script -Wl,\$(top_srcdir)/vscript\n\n";
+print MAKE "libc_la_LDFLAGS = -Wc,-lgcc_s -Wc,-nostdlib -version-info 5:0:0 -Wl,--version-script -Wl,\$(top_srcdir)/vscript\n\n";
 
+print MAKE "# libg.a is used when -g option is given during linking.\n";
+print MAKE "libg_la_SOURCES = \$(libc_la_SOURCES)\n\n";
+
+print MAKE "libg_la_LDFLAGS = -Wc,-lgcc_s -Wc,-nostdlib -version-info 5:0:0 -Wl,--version-script -Wl,\$(top_srcdir)/vscript\n\n";
+
+print MAKE "libm_la_SOURCES = libm-support/libm.c\n\n";
+
 print MAKE "libm_la_LDFLAGS = -Wc,-nostdlib -version-info 1:0:0\n\n";
 
 print MAKE "toolexeclib_DATA = crt0.o gcrt0.o\n\n";
@@ -241,11 +246,11 @@
 
 print MAKE "install-data-local: install-headers\n\n";
 print MAKE "install-headers:\n";
-print MAKE "\t\$(mkinstalldirs) \$(DESTDIR)\${tooldir}/include/libunixlib\n";
+print MAKE "\t\$(mkinstalldirs) \$(DESTDIR)\${tooldir}/include\n";
 print MAKE "\tfor dir in arpa bits net netinet resolv rpc string sys unixlib; do \\\n";
-print MAKE "\t  \$(mkinstalldirs) \$(DESTDIR)\${tooldir}/include/libunixlib/\$\${dir} ; done\n";
+print MAKE "\t  \$(mkinstalldirs) \$(DESTDIR)\${tooldir}/include/\$\${dir} ; done\n";
 print MAKE "\tfor file in \${libc_headers}; do \\\n";
-print MAKE "\t  \$(INSTALL_DATA) \$(srcdir)/include/\$\${file} \$(DESTDIR)\${tooldir}/include/libunixlib/\$\${file} ; done\n";
+print MAKE "\t  \$(INSTALL_DATA) \$(srcdir)/include/\$\${file} \$(DESTDIR)\${tooldir}/include/\$\${file} ; done\n";
 
 print MAKE "\n";
 close MAKE;
