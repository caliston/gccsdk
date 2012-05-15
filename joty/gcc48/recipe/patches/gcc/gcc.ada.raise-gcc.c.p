Index: gcc/ada/raise-gcc.c
===================================================================
--- gcc/ada/raise-gcc.c	(revision 187550)
+++ gcc/ada/raise-gcc.c	(working copy)
@@ -1102,7 +1102,11 @@
 	return __gnat_handle_vms_condition (version_arg, phases_arg);
 #endif
 
-      return _URC_FATAL_PHASE1_ERROR;
+#ifdef __ARM_EABI_UNWINDER__
+      return _URC_FAILURE;
+#else
+       return _URC_FATAL_PHASE1_ERROR;
+#endif
     }
 
   db_indent (DB_INDENT_RESET);
