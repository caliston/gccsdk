Index: gcc/function.c
===================================================================
--- gcc/function.c	(revision 166917)
+++ gcc/function.c	(working copy)
@@ -4887,6 +4887,17 @@
   force_next_line_note ();
   set_curr_insn_source_location (input_location);
 
+  /* If we had calls to alloca, and this machine needs
+     an accurate stack pointer to exit the function,
+     insert some code to save and restore the stack pointer.  */
+  if (! EXIT_IGNORE_STACK && cfun->calls_alloca)
+    {
+      rtx tem = 0;
+
+      emit_stack_save (SAVE_FUNCTION, &tem, parm_birth_insn);
+      emit_stack_restore (SAVE_FUNCTION, tem, NULL_RTX);
+    }
+
   /* Before the return label (if any), clobber the return
      registers so that they are not propagated live to the rest of
      the function.  This can only happen with functions that drop
