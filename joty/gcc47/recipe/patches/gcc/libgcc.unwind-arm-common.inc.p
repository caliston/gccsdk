Index: libgcc/unwind-arm-common.inc
===================================================================
--- libgcc/unwind-arm-common.inc	(revision 178826)
+++ libgcc/unwind-arm-common.inc	(working copy)
@@ -94,8 +94,9 @@
 extern int __data_start;
 
 /* The exception index table location.  */
-extern __EIT_entry __exidx_start;
-extern __EIT_entry __exidx_end;
+/* RISC OS: These must be const so that in module code, they are not relocated.  */
+extern const __EIT_entry __exidx_start;
+extern const __EIT_entry __exidx_end;
 
 /* Core unwinding functions.  */
 
@@ -239,6 +240,14 @@
 
   do
     {
+#ifdef __riscos__
+      __ehs_unwind_stack_chunk ((void **)&VRS_FP (vrs),
+				(void *)ucbp->alloca_fp,
+				(void **)&VRS_PC (vrs),
+				(void **)&VRS_SL (vrs));
+      ucbp->alloca_fp = VRS_FP (vrs);
+#endif
+
       /* Find the entry for this routine.  */
       if (get_eit_entry (ucbp, VRS_PC(vrs)) != _URC_OK)
 	abort ();
@@ -254,6 +263,10 @@
   if (pr_result != _URC_INSTALL_CONTEXT)
     abort();
   
+#ifdef __riscos__
+  fixup_stack (&vrs->core);
+#endif
+
   restore_core_regs (&vrs->core);
 }
 
@@ -283,6 +296,14 @@
       _Unwind_Reason_Code entry_code;
       _Unwind_Reason_Code stop_code;
 
+#ifdef __riscos__
+      __ehs_unwind_stack_chunk ((void **)&VRS_FP (&saved_vrs),
+				(void *)ucbp->alloca_fp,
+				(void **)&VRS_PC (&saved_vrs),
+				(void **)&VRS_SL (&saved_vrs));
+      ucbp->alloca_fp = VRS_FP (&saved_vrs);
+#endif
+
       /* Find the entry for this routine.  */
       entry_code = get_eit_entry (ucbp, VRS_PC (&saved_vrs));
 
@@ -339,6 +360,10 @@
       return _URC_FAILURE;
     }
 
+#ifdef __riscos__
+  fixup_stack (&saved_vrs.core);
+#endif
+
   restore_core_regs (&saved_vrs.core);
 }
 
@@ -368,6 +393,10 @@
   phase1_vrs saved_vrs;
   _Unwind_Reason_Code pr_result;
 
+#ifdef __riscos__
+  ucbp->alloca_fp = VRS_FP (entry_vrs);
+#endif
+
   /* Set the pc to the call site.  */
   VRS_PC (entry_vrs) = VRS_RETURN(entry_vrs);
 
@@ -379,6 +408,14 @@
   /* Unwind until we reach a propagation barrier.  */
   do
     {
+#ifdef __riscos__
+      __ehs_unwind_stack_chunk ((void **)&VRS_FP (&saved_vrs),
+				(void *)ucbp->alloca_fp,
+				(void **)&VRS_PC (&saved_vrs),
+				(void **)&VRS_SL (&saved_vrs));
+      ucbp->alloca_fp = VRS_FP (&saved_vrs);
+#endif
+
       /* Find the entry for this routine.  */
       if (get_eit_entry (ucbp, VRS_PC (&saved_vrs)) != _URC_OK)
 	return _URC_FAILURE;
@@ -442,6 +479,10 @@
       abort ();
     }
 
+#ifdef __riscos__
+  ucbp->alloca_fp = VRS_FP (entry_vrs);
+#endif
+
   /* Call the cached PR.  */
   pr_result = ((personality_routine) UCB_PR_ADDR (ucbp))
 	(_US_UNWIND_FRAME_RESUME, ucbp, (_Unwind_Context *) entry_vrs);
@@ -449,6 +490,9 @@
   switch (pr_result)
     {
     case _URC_INSTALL_CONTEXT:
+#ifdef __riscos__
+      fixup_stack (&entry_vrs->core);
+#endif
       /* Upload the registers to enter the landing pad.  */
       restore_core_regs (&entry_vrs->core);
 
@@ -471,6 +515,10 @@
   if (!UCB_FORCED_STOP_FN (ucbp))
     return __gnu_Unwind_RaiseException (ucbp, entry_vrs);
 
+#ifdef __riscos__
+  ucbp->alloca_fp = VRS_FP (entry_vrs);
+#endif
+
   /* Set the pc to the call site.  */
   VRS_PC (entry_vrs) = VRS_RETURN (entry_vrs);
   /* Continue unwinding the next frame.  */
@@ -518,6 +566,14 @@
   
   do
     {
+#ifdef __riscos__
+      __ehs_unwind_stack_chunk ((void **)&VRS_FP (&saved_vrs),
+				(void *)ucbp->alloca_fp,
+				(void **)&VRS_PC (&saved_vrs),
+				(void **)&VRS_SL (&saved_vrs));
+      ucbp->alloca_fp = VRS_FP (&saved_vrs);
+#endif
+
       /* Find the entry for this routine.  */
       if (get_eit_entry (ucbp, VRS_PC (&saved_vrs)) != _URC_OK)
 	{
