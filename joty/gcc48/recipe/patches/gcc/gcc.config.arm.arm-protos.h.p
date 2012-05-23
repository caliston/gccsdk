Index: gcc/config/arm/arm-protos.h
===================================================================
--- gcc/config/arm/arm-protos.h	(revision 187811)
+++ gcc/config/arm/arm-protos.h	(working copy)
@@ -256,4 +256,13 @@
 
 extern bool arm_autoinc_modes_ok_p (enum machine_mode, enum arm_auto_incmodes);
 
+extern bool arm_apcs_frame_needed (void);
+extern void arm_expand_save_stack_block (rtx, rtx);
+extern void arm_expand_restore_stack_block (rtx, rtx);
+extern void arm_expand_alloca_epilogue (void);
+extern void arm_expand_allocate_stack (rtx, rtx);
+extern void arm_expand_save_stack_nonlocal (rtx *);
+extern void arm_expand_restore_stack_nonlocal (rtx *);
+extern void arm_expand_nonlocal_goto (rtx *);
+
 #endif /* ! GCC_ARM_PROTOS_H */
