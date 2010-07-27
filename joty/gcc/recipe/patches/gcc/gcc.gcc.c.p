Index: gcc/gcc.c
===================================================================
--- gcc/gcc.c	(revision 162611)
+++ gcc/gcc.c	(working copy)
@@ -371,7 +371,7 @@
 static void init_gcc_specs (struct obstack *, const char *, const char *,
 			    const char *);
 #endif
-#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX)
+#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined(TARGET_CONVERT_FILENAME)
 static const char *convert_filename (const char *, int, int);
 #endif
 
@@ -3301,7 +3301,7 @@
 
 const char **outfiles;
 
-#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX)
+#if defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined (TARGET_CONVERT_FILENAME)
 
 /* Convert NAME to a new name if it is the standard suffix.  DO_EXE
    is true if we should look for an executable suffix.  DO_OBJ
@@ -3311,6 +3311,9 @@
 convert_filename (const char *name, int do_exe ATTRIBUTE_UNUSED,
 		  int do_obj ATTRIBUTE_UNUSED)
 {
+#ifdef TARGET_CONVERT_FILENAME
+  TARGET_CONVERT_FILENAME(&obstack, name, do_exe, do_obj);
+#else
 #if defined(HAVE_TARGET_EXECUTABLE_SUFFIX)
   int i;
 #endif
@@ -3354,6 +3357,7 @@
 #endif
 
   return name;
+#endif /* ! TARGET_CONVERT_FILENAME */
 }
 #endif
 
@@ -4158,7 +4162,7 @@
 		    }
 		}
 #endif
-#if defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined(HAVE_TARGET_OBJECT_SUFFIX)
+#if defined(HAVE_TARGET_EXECUTABLE_SUFFIX) || defined(HAVE_TARGET_OBJECT_SUFFIX) || defined(TARGET_CONVERT_FILENAME)
 	      if (p[1] == 0)
 		argv[i + 1] = convert_filename (argv[i + 1], ! have_c, 0);
 	      else
@@ -4245,7 +4249,7 @@
           char *fname;
 	  long offset;
 	  int consumed;
-#ifdef HAVE_TARGET_OBJECT_SUFFIX
+#if defined (HAVE_TARGET_OBJECT_SUFFIX) || defined (TARGET_CONVERT_FILENAME)
 	  argv[i] = convert_filename (argv[i], 0, access (argv[i], F_OK));
 #endif
 	  /* For LTO static archive support we handle input file
