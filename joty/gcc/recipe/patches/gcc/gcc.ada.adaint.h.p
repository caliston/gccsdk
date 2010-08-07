Index: gcc/ada/adaint.h
===================================================================
--- gcc/ada/adaint.h	(revision 162881)
+++ gcc/ada/adaint.h	(working copy)
@@ -130,6 +130,7 @@
 extern int    __gnat_open_rw                       (char *, int);
 extern int    __gnat_open_create                   (char *, int);
 extern int    __gnat_create_output_file            (char *);
+extern int    __gnat_create_output_file_new        (char *);
 extern int    __gnat_open_append                   (char *, int);
 extern long   __gnat_file_length                   (int);
 extern long   __gnat_named_file_length             (char *);
