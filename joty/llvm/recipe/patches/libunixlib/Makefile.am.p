Index: Makefile.am
===================================================================
--- Makefile.am	(revision 4658)
+++ Makefile.am	(working copy)
@@ -1388,7 +1388,7 @@
 	incl-local/time.h \
 	incl-local/unistd.h
 
-libunixlib_la_SOURCES = $(assert_src) $(common_src) $(crypt_src) $(ctype_src) \
+libc_la_SOURCES = $(assert_src) $(common_src) $(crypt_src) $(ctype_src) \
 	$(debug_src) $(fenv_src) $(gcccompat_src) $(gdtoa_src) $(gmon_src) \
 	$(grp_src) $(inttypes_src) $(kernel_src) \
 	$(libm_complex_src) $(libm_dbl64_src) $(libm_flt32_src) $(libm_generic_src) $(libm_support_src) \
@@ -1398,13 +1398,18 @@
 	$(stdio_src) $(stdlib_src) $(string_src) $(sys_src) \
 	$(termios_src) $(time_src) $(unistd_src) $(unix_src) $(wchar_src)
 
-libunixlib_la_LDFLAGS = -Wc,-lgcc_s -Wc,-nostdlib -version-info 5:0:0 -Wl,--version-script -Wl,$(top_srcdir)/vscript
+libc_la_LDFLAGS = -Wc,-lgcc_s -Wc,-nostdlib -version-info 5:0:0 -Wl,--version-script -Wl,$(top_srcdir)/vscript
 
+# libg.a is used when -g option is given during linking.
+libg_la_SOURCES = $(libc_la_SOURCES)
+
+libg_la_LDFLAGS = $(libc_la_LDFLAGS)
+
 libm_la_SOURCES = libm-support/libm.c
 
 libm_la_LDFLAGS = -Wc,-nostdlib -version-info 1:0:0
 
-toolexeclib_LTLIBRARIES = libunixlib.la libm.la
+toolexeclib_LTLIBRARIES = libc.la libg.la libm.la
 
 # crt ----------------------
 
