--- bin/Makefile.in.orig	2009-08-28 11:23:24.000000000 -0700
+++ bin/Makefile.in	2009-08-28 11:26:29.000000000 -0700
@@ -34,8 +34,8 @@
 host_triplet = @host@
 bin_PROGRAMS = vlc$(EXEEXT) $(am__EXEEXT_1)
 noinst_PROGRAMS = vlc-static$(EXEEXT)
-EXTRA_PROGRAMS = vlc-wrapper$(EXEEXT)
-@HAVE_WIN32_FALSE@@HAVE_WINCE_FALSE@am__append_1 = vlc-wrapper
+#EXTRA_PROGRAMS = vlc-wrapper$(EXEEXT)
+#@HAVE_WIN32_FALSE@@HAVE_WINCE_FALSE@am__append_1 = vlc-wrapper
 @HAVE_WIN32_TRUE@am__append_2 = -lwininet vlc_win32_rc.$(OBJEXT)
 @HAVE_WIN32_TRUE@am__append_3 = vlc_win32_rc.$(OBJEXT)
 subdir = bin
@@ -55,8 +55,8 @@
 mkinstalldirs = $(install_sh) -d
 CONFIG_HEADER = $(top_builddir)/config.h
 CONFIG_CLEAN_FILES =
-@HAVE_WIN32_FALSE@@HAVE_WINCE_FALSE@am__EXEEXT_1 =  \
-@HAVE_WIN32_FALSE@@HAVE_WINCE_FALSE@	vlc-wrapper$(EXEEXT)
+#@HAVE_WIN32_FALSE@@HAVE_WINCE_FALSE@am__EXEEXT_1 =  \
+#@HAVE_WIN32_FALSE@@HAVE_WINCE_FALSE@	vlc-wrapper$(EXEEXT)
 am__installdirs = "$(DESTDIR)$(bindir)"
 binPROGRAMS_INSTALL = $(INSTALL_PROGRAM)
 PROGRAMS = $(bin_PROGRAMS) $(noinst_PROGRAMS)