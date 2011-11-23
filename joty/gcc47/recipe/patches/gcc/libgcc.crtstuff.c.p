Index: libgcc/crtstuff.c
===================================================================
--- libgcc/crtstuff.c	(revision 181632)
+++ libgcc/crtstuff.c	(working copy)
@@ -209,13 +209,13 @@
 #elif defined(CTORS_SECTION_ASM_OP)
 /* Hack: force cc1 to switch to .data section early, so that assembling
    __CTOR_LIST__ does not undo our behind-the-back change to .ctors.  */
-static func_ptr force_to_data[1] __attribute__ ((__used__)) = { };
+static const func_ptr force_to_data[1] __attribute__ ((__used__)) = { };
 asm (CTORS_SECTION_ASM_OP);
-STATIC func_ptr __CTOR_LIST__[1]
+STATIC const func_ptr __CTOR_LIST__[1]
   __attribute__ ((__used__, aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #else
-STATIC func_ptr __CTOR_LIST__[1]
+STATIC const func_ptr __CTOR_LIST__[1]
   __attribute__ ((__used__, section(".ctors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #endif /* __CTOR_LIST__ alternatives */
@@ -224,11 +224,11 @@
 DTOR_LIST_BEGIN;
 #elif defined(DTORS_SECTION_ASM_OP)
 asm (DTORS_SECTION_ASM_OP);
-STATIC func_ptr __DTOR_LIST__[1]
+STATIC const func_ptr __DTOR_LIST__[1]
   __attribute__ ((aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #else
-STATIC func_ptr __DTOR_LIST__[1]
+STATIC const func_ptr __DTOR_LIST__[1]
   __attribute__((section(".dtors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #endif /* __DTOR_LIST__ alternatives */
@@ -251,10 +251,10 @@
 #endif /* JCR_SECTION_NAME */
 
 #if USE_TM_CLONE_REGISTRY
-STATIC func_ptr __TMC_LIST__[]
+STATIC const func_ptr __TMC_LIST__[]
   __attribute__((unused, section(".tm_clone_table"), aligned(sizeof(void*))))
   = { };
-extern func_ptr __TMC_END__[] __attribute__((__visibility__ ("hidden")));
+extern const func_ptr __TMC_END__[] __attribute__((__visibility__ ("hidden")));
 #endif /* USE_TM_CLONE_REGISTRY */
 
 #if defined(INIT_SECTION_ASM_OP) || defined(INIT_ARRAY_SECTION_ASM_OP)
@@ -318,11 +318,11 @@
 #ifdef FINI_ARRAY_SECTION_ASM_OP
   /* If we are using .fini_array then destructors will be run via that
      mechanism.  */
-#elif defined(HIDDEN_DTOR_LIST_END)
+#elif defined(HIDDEN_DTOR_LIST_END) && !defined(__riscos__)
   {
     /* Safer version that makes sure only .dtors function pointers are
        called even if the static variable is maliciously changed.  */
-    extern func_ptr __DTOR_END__[] __attribute__((visibility ("hidden")));
+    extern const func_ptr __DTOR_END__[] __attribute__((visibility ("hidden")));
     static size_t dtor_idx;
     const size_t max_idx = __DTOR_END__ - __DTOR_LIST__ - 1;
     func_ptr f;
@@ -334,8 +334,12 @@
       }
   }
 #else /* !defined (FINI_ARRAY_SECTION_ASM_OP) */
+  /* For RISC OS we force this code to be used, as the default choice above produces
+     code that doesn't work. The compiler optimises so aggressively that it assumes
+     that the array only ever contains one value of -1. The code produced does not
+     look at the array, but simply jumps directly to 0xFFFFFFFF.  */
   {
-    static func_ptr *p = __DTOR_LIST__ + 1;
+    static const func_ptr *p = __DTOR_LIST__ + 1;
     func_ptr f;
 
     while ((f = *p))
@@ -375,7 +379,7 @@
 #ifdef FINI_SECTION_ASM_OP
 CRT_CALL_STATIC_FUNCTION (FINI_SECTION_ASM_OP, __do_global_dtors_aux)
 #elif defined (FINI_ARRAY_SECTION_ASM_OP)
-static func_ptr __do_global_dtors_aux_fini_array_entry[]
+static const func_ptr __do_global_dtors_aux_fini_array_entry[]
   __attribute__ ((__used__, section(".fini_array")))
   = { __do_global_dtors_aux };
 #else /* !FINI_SECTION_ASM_OP && !FINI_ARRAY_SECTION_ASM_OP */
@@ -495,7 +499,7 @@
 void
 __do_global_dtors (void)
 {
-  func_ptr *p, f;
+  const func_ptr *p, f;
   for (p = __DTOR_LIST__ + 1; (f = *p); p++)
     f ();
 
@@ -578,11 +582,11 @@
    __CTOR_LIST__ does not undo our behind-the-back change to .ctors.  */
 static func_ptr force_to_data[1] __attribute__ ((__used__)) = { };
 asm (CTORS_SECTION_ASM_OP);
-STATIC func_ptr __CTOR_END__[1]
+STATIC const func_ptr __CTOR_END__[1]
   __attribute__((aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #else
-STATIC func_ptr __CTOR_END__[1]
+STATIC const func_ptr __CTOR_END__[1]
   __attribute__((section(".ctors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #endif
@@ -593,7 +597,7 @@
 #ifdef DTORS_SECTION_ASM_OP
 asm (DTORS_SECTION_ASM_OP);
 #endif
-func_ptr __DTOR_END__[1]
+const func_ptr __DTOR_END__[1]
   __attribute__ ((used,
 #ifndef DTORS_SECTION_ASM_OP
 		  section(".dtors"),
@@ -602,11 +606,11 @@
   = { (func_ptr) 0 };
 #elif defined(DTORS_SECTION_ASM_OP)
 asm (DTORS_SECTION_ASM_OP);
-STATIC func_ptr __DTOR_END__[1]
+STATIC const func_ptr __DTOR_END__[1]
   __attribute__ ((used, aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #else
-STATIC func_ptr __DTOR_END__[1]
+STATIC const func_ptr __DTOR_END__[1]
   __attribute__((used, section(".dtors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #endif
@@ -655,7 +659,7 @@
 static void __attribute__((used))
 __do_global_ctors_aux (void)
 {
-  func_ptr *p;
+  const func_ptr *p;
   for (p = __CTOR_END__ - 1; *p != (func_ptr) -1; p--)
     (*p) ();
 }
@@ -708,7 +712,7 @@
 void
 __do_global_ctors (void)
 {
-  func_ptr *p;
+  const func_ptr *p;
 #if defined(USE_EH_FRAME_REGISTRY) \
     || defined(JCR_SECTION_NAME) \
     || defined(USE_TM_CLONE_REGISTRY)
