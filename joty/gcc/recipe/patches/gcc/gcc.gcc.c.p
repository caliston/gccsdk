Index: gcc/gcc.c
===================================================================
--- gcc/gcc.c	(revision 168734)
+++ gcc/gcc.c	(working copy)
@@ -247,7 +247,7 @@
 static void init_gcc_specs (struct obstack *, const char *, const char *,
 			    const char *);
 #endif
-#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX)
+#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined(TARGET_CONVERT_FILENAME)
 static const char *convert_filename (const char *, int, int);
 #endif
 
@@ -2842,7 +2842,7 @@
 
 const char **outfiles;
 
-#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX)
+#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined (TARGET_CONVERT_FILENAME)
 
 /* Convert NAME to a new name if it is the standard suffix.  DO_EXE
    is true if we should look for an executable suffix.  DO_OBJ
@@ -2852,6 +2852,9 @@
 convert_filename (const char *name, int do_exe ATTRIBUTE_UNUSED,
 		  int do_obj ATTRIBUTE_UNUSED)
 {
+#ifdef TARGET_CONVERT_FILENAME
+  TARGET_CONVERT_FILENAME(&obstack, name, do_exe, do_obj);
+#else
 #if defined(HAVE_TARGET_EXECUTABLE_SUFFIX)
   int i;
 #endif
@@ -2895,6 +2898,7 @@
 #endif
 
   return name;
+#endif /* ! TARGET_CONVERT_FILENAME */
 }
 #endif
 
@@ -3441,7 +3445,7 @@
 
     case OPT_o:
       have_o = 1;
-#if defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined(HAVE_TARGET_OBJECT_SUFFIX)
+#if defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(TARGET_CONVERT_FILENAME)
       arg = convert_filename (arg, ! have_c, 0);
 #endif
       /* Save the output name in case -save-temps=obj was used.  */
@@ -3737,7 +3741,7 @@
           char *fname;
 	  long offset;
 	  int consumed;
-#ifdef HAVE_TARGET_OBJECT_SUFFIX
+#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(TARGET_CONVERT_FILENAME)
 	  arg = convert_filename (arg, 0, access (arg, F_OK));
 #endif
 	  /* For LTO static archive support we handle input file
