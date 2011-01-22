Index: gcc/config/arm/unwind-arm.h
===================================================================
--- gcc/config/arm/unwind-arm.h	(revision 168231)
+++ gcc/config/arm/unwind-arm.h	(working copy)
@@ -228,7 +228,7 @@
       if (!tmp)
 	return 0;
 
-#if (defined(linux) && !defined(__uClinux__)) || defined(__NetBSD__)
+#if (defined(linux) && !defined(__uClinux__)) || defined(__NetBSD__) || defined(__riscos__)
       /* Pc-relative indirect.  */
       tmp += ptr;
       tmp = *(_Unwind_Word *) tmp;
