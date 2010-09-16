Index: gcc/config/arm/arm.h
===================================================================
--- gcc/config/arm/arm.h	(revision 164317)
+++ gcc/config/arm/arm.h	(working copy)
@@ -204,6 +204,12 @@
 #define SUBTARGET_CPP_SPEC      ""
 #endif
 
+#ifndef SUBTARGET_OPTION_TRANSLATE_TABLE
+#define SUBTARGET_OPTION_TRANSLATE_TABLE { "", "" }
+#endif
+#define TARGET_OPTION_TRANSLATE_TABLE \
+  SUBTARGET_OPTION_TRANSLATE_TABLE
+
 /* Run-time Target Specification.  */
 #ifndef TARGET_VERSION
 #define TARGET_VERSION fputs (" (ARM/generic)", stderr);
@@ -227,7 +233,7 @@
 				         : TARGET_TPCS_FRAME)
 #define TARGET_LDRD			(arm_arch5e && ARM_DOUBLEWORD_ALIGN)
 #define TARGET_AAPCS_BASED \
-    (arm_abi != ARM_ABI_APCS && arm_abi != ARM_ABI_ATPCS)
+    (arm_abi != ARM_ABI_APCS && arm_abi != ARM_ABI_ATPCS && arm_abi != ARM_ABI_APCS32)
 
 #define TARGET_HARD_TP			(target_thread_pointer == TP_CP15)
 #define TARGET_SOFT_TP			(target_thread_pointer == TP_SOFT)
@@ -399,7 +405,8 @@
   ARM_ABI_ATPCS,
   ARM_ABI_AAPCS,
   ARM_ABI_IWMMXT,
-  ARM_ABI_AAPCS_LINUX
+  ARM_ABI_AAPCS_LINUX,
+  ARM_ABI_APCS32
 };
 
 extern enum arm_abi_type arm_abi;
@@ -882,10 +889,10 @@
       fixed_regs[PIC_OFFSET_TABLE_REGNUM] = 1;			\
       call_used_regs[PIC_OFFSET_TABLE_REGNUM] = 1;		\
     }								\
-  else if (TARGET_APCS_STACK)					\
+  if (OPTION_APCS_STACK)					\
     {								\
-      fixed_regs[10]     = 1;					\
-      call_used_regs[10] = 1;					\
+      fixed_regs[SL_REGNUM]     = 1;				\
+      call_used_regs[SL_REGNUM] = 1;				\
     }								\
   /* -mcaller-super-interworking reserves r11 for calls to	\
      _interwork_r11_call_via_rN().  Making the register global	\
@@ -954,9 +961,14 @@
 #define LAST_HI_REGNUM		11
 
 #ifndef TARGET_UNWIND_INFO
+/* FIXME: GCCSDK: why not define TARGET_UNWIND_INFO ? */
+/* We use sjlj exceptions for backwards compatibility.
+   For RISC OS, we will not use SJLJ.  */
+#ifndef TARGET_RISCOSELF
 /* We use sjlj exceptions for backwards compatibility.  */
 #define MUST_USE_SJLJ_EXCEPTIONS 1
 #endif
+#endif
 
 /* We can generate DWARF2 Unwind info, even though we don't use it.  */
 #define DWARF2_UNWIND_INFO 1
@@ -1018,10 +1030,18 @@
   (((REGNUM) >= FIRST_IWMMXT_GR_REGNUM) && ((REGNUM) <= LAST_IWMMXT_GR_REGNUM))
 
 /* Base register for access to local variables of the function.  */
+#ifdef TARGET_RISCOSELF
+#define FRAME_POINTER_REGNUM	9
+#else
 #define FRAME_POINTER_REGNUM	25
+#endif
 
 /* Base register for access to arguments of the function.  */
+#ifdef TARGET_RISCOSELF
+#define ARG_POINTER_REGNUM	ARM_HARD_FRAME_POINTER_REGNUM
+#else
 #define ARG_POINTER_REGNUM	26
+#endif
 
 #define FIRST_CIRRUS_FP_REGNUM	27
 #define LAST_CIRRUS_FP_REGNUM	42
@@ -1506,7 +1526,7 @@
    is at the high-address end of the local variables;
    that is, each additional local variable allocated
    goes at a more negative offset in the frame.  */
-#define FRAME_GROWS_DOWNWARD 1
+#define FRAME_GROWS_DOWNWARD ((arm_abi == ARM_ABI_APCS32) ? 0 : 1)
 
 /* The amount of scratch space needed by _interwork_{r7,r11}_call_via_rN().
    When present, it is one word in size, and sits at the top of the frame,
@@ -1526,7 +1546,8 @@
    If FRAME_GROWS_DOWNWARD, this is the offset to the END of the
    first local allocated.  Otherwise, it is the offset to the BEGINNING
    of the first local allocated.  */
-#define STARTING_FRAME_OFFSET  0
+#define STARTING_FRAME_OFFSET		\
+   (arm_abi == ARM_ABI_APCS32 ? crtl->outgoing_args_size : 0)
 
 /* If we generate an insn to push BYTES bytes,
    this says how many the stack pointer really advances by.  */
@@ -1627,6 +1648,7 @@
   int soft_frame;	/* FRAME_POINTER_REGNUM.  */
   int locals_base;	/* THUMB_HARD_FRAME_POINTER_REGNUM.  */
   int outgoing_args;	/* STACK_POINTER_REGNUM.  */
+  int frame_size;	/* get_frame_size() */
   unsigned int saved_regs_mask;
 }
 arm_stack_offsets;
@@ -1653,6 +1675,8 @@
   /* Records if sibcalls are blocked because an argument
      register is needed to preserve stack alignment.  */
   int sibcall_blocked;
+  /* Non-zero if this is a leaf function.  */
+  int leaf;
   /* The PIC register for this function.  This might be a pseudo.  */
   rtx pic_reg;
   /* Labels for per-function Thumb call-via stubs.  One per potential calling
@@ -1705,6 +1729,8 @@
   int nregs;
   /* This is the number of iWMMXt register arguments scanned so far.  */
   int iwmmxt_nregs;
+  /* This is the number of FPA register arguments scanned so far.  */
+  int fpa_nregs;
   int named_count;
   int nargs;
   /* Which procedure call variant to use for this call.  */
@@ -1763,6 +1789,8 @@
    (IN_RANGE ((REGNO), 0, 3)						\
     || (TARGET_AAPCS_BASED && TARGET_VFP && TARGET_HARD_FLOAT		\
 	&& IN_RANGE ((REGNO), FIRST_VFP_REGNUM, FIRST_VFP_REGNUM + 15))	\
+    || (TARGET_FPA && TARGET_APCS_FLOAT					\
+        && IN_RANGE ((REGNO), FIRST_FPA_REGNUM, FIRST_FPA_REGNUM + 3))	\
     || (TARGET_IWMMXT_ABI						\
 	&& IN_RANGE ((REGNO), FIRST_IWMMXT_REGNUM, FIRST_IWMMXT_REGNUM + 9)))
 
@@ -1849,6 +1877,11 @@
    pointer.  Note we have to use {ARM|THUMB}_HARD_FRAME_POINTER_REGNUM
    because the definition of HARD_FRAME_POINTER_REGNUM is not a constant.  */
 
+#ifdef TARGET_RISCOSELF
+#define ELIMINABLE_REGS                                         \
+{{ ARG_POINTER_REGNUM,        STACK_POINTER_REGNUM            },\
+ { FRAME_POINTER_REGNUM,      STACK_POINTER_REGNUM            }}
+#else
 #define ELIMINABLE_REGS						\
 {{ ARG_POINTER_REGNUM,        STACK_POINTER_REGNUM            },\
  { ARG_POINTER_REGNUM,        FRAME_POINTER_REGNUM            },\
@@ -1857,6 +1890,7 @@
  { FRAME_POINTER_REGNUM,      STACK_POINTER_REGNUM            },\
  { FRAME_POINTER_REGNUM,      ARM_HARD_FRAME_POINTER_REGNUM   },\
  { FRAME_POINTER_REGNUM,      THUMB_HARD_FRAME_POINTER_REGNUM }}
+#endif
 
 /* Define the offset between two registers, one to be eliminated, and the
    other its replacement, at the start of a routine.  */
@@ -1902,8 +1936,8 @@
 /* Don't allow the pc to be used.  */
 #define ARM_REGNO_OK_FOR_BASE_P(REGNO)			\
   (TEST_REGNO (REGNO, <, PC_REGNUM)			\
-   || TEST_REGNO (REGNO, ==, FRAME_POINTER_REGNUM)	\
-   || TEST_REGNO (REGNO, ==, ARG_POINTER_REGNUM))
+   || (!OPTION_APCS_STACK && TEST_REGNO (REGNO, ==, FRAME_POINTER_REGNUM)) \
+   || (!OPTION_APCS_STACK && TEST_REGNO (REGNO, ==, ARG_POINTER_REGNUM)))
 
 #define THUMB1_REGNO_MODE_OK_FOR_BASE_P(REGNO, MODE)		\
   (TEST_REGNO (REGNO, <=, LAST_LO_REGNUM)			\
@@ -1991,6 +2025,11 @@
   if (TARGET_THUMB2)			\
     thumb2_asm_output_opcode (STREAM);
 
+#ifdef TARGET_RISCOSELF
+/* Defining CTORS_SECTION_ASM_OP makes the asm() hacks in crtstuff.c generate
+   code which breaks the module case (cfr. "Hack: force cc1 to switch to .data
+   section early," comment).  */
+#else
 /* The EABI specifies that constructors should go in .init_array.
    Other targets use .ctors for compatibility.  */
 #ifndef ARM_EABI_CTORS_SECTION_OP
@@ -2036,6 +2075,7 @@
 #   define DTORS_SECTION_ASM_OP ARM_DTORS_SECTION_OP
 # endif /* !defined (__ARM_EABI__) */
 #endif /* !defined (IN_LIBCC2) */
+#endif
 
 /* True if the operating system can merge entities with vague linkage
    (e.g., symbols in COMDAT group) during dynamic linking.  */
@@ -2064,8 +2104,8 @@
 #define ARM_REG_OK_FOR_BASE_P(X)		\
   (REGNO (X) <= LAST_ARM_REGNUM			\
    || REGNO (X) >= FIRST_PSEUDO_REGISTER	\
-   || REGNO (X) == FRAME_POINTER_REGNUM		\
-   || REGNO (X) == ARG_POINTER_REGNUM)
+   || (!OPTION_APCS_STACK && REGNO (X) == FRAME_POINTER_REGNUM) \
+   || (!OPTION_APCS_STACK && REGNO (X) == ARG_POINTER_REGNUM))
 
 #define ARM_REG_OK_FOR_INDEX_P(X)		\
   ((REGNO (X) <= LAST_ARM_REGNUM		\
