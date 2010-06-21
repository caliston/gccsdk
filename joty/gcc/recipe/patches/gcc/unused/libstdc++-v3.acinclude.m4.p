Index: libstdc++-v3/acinclude.m4
===================================================================
--- libstdc++-v3/acinclude.m4	(revision 161061)
+++ libstdc++-v3/acinclude.m4	(working copy)
@@ -49,7 +49,7 @@
   # Keep these sync'd with the list in Makefile.am.  The first provides an
   # expandable list at autoconf time; the second provides an expandable list
   # (i.e., shell variable) at configure time.
-  m4_define([glibcxx_SUBDIRS],[include libsupc++ python src doc po testsuite])
+  m4_define([glibcxx_SUBDIRS],[include riscos libsupc++ python src doc po testsuite])
   SUBDIRS='glibcxx_SUBDIRS'
 
   # These need to be absolute paths, yet at the same time need to
