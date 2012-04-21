--- gcc/crtstuff.c.orig	2012-03-21 20:08:27.000000000 +0000
+++ gcc/crtstuff.c	2012-03-21 20:03:34.000000000 +0000
@@ -181,7 +181,7 @@ STATIC func_ptr __CTOR_LIST__[1]
   __attribute__ ((__unused__, aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #else
-STATIC func_ptr __CTOR_LIST__[1]
+STATIC const func_ptr __CTOR_LIST__[1]
   __attribute__ ((__unused__, section(".ctors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #endif /* __CTOR_LIST__ alternatives */
@@ -194,7 +194,7 @@ STATIC func_ptr __DTOR_LIST__[1]
   __attribute__ ((aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #else
-STATIC func_ptr __DTOR_LIST__[1]
+STATIC const func_ptr __DTOR_LIST__[1]
   __attribute__((section(".dtors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) (-1) };
 #endif /* __DTOR_LIST__ alternatives */
@@ -261,7 +261,7 @@ static void __attribute__((used))
 __do_global_dtors_aux (void)
 {
 #ifndef FINI_ARRAY_SECTION_ASM_OP
-  static func_ptr *p = __DTOR_LIST__ + 1;
+  static const func_ptr *p = __DTOR_LIST__ + 1;
   func_ptr f;
 #endif /* !defined(FINI_ARRAY_SECTION_ASM_OP)  */
   static _Bool completed;
@@ -401,7 +401,7 @@ extern void __do_global_dtors (void);
 void
 __do_global_dtors (void)
 {
-  func_ptr *p, f;
+  const func_ptr *p, f;
   for (p = __DTOR_LIST__ + 1; (f = *p); p++)
     f ();
 
@@ -459,7 +459,7 @@ STATIC func_ptr __CTOR_END__[1]
   __attribute__((aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #else
-STATIC func_ptr __CTOR_END__[1]
+STATIC const func_ptr __CTOR_END__[1]
   __attribute__((section(".ctors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #endif
@@ -472,7 +472,7 @@ STATIC func_ptr __DTOR_END__[1]
   __attribute__ ((unused, aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #else
-STATIC func_ptr __DTOR_END__[1]
+STATIC const func_ptr __DTOR_END__[1]
   __attribute__((unused, section(".dtors"), aligned(sizeof(func_ptr))))
   = { (func_ptr) 0 };
 #endif
@@ -513,7 +513,7 @@ STATIC void *__JCR_END__[1]
 static void __attribute__((used))
 __do_global_ctors_aux (void)
 {
-  func_ptr *p;
+  const func_ptr *p;
   for (p = __CTOR_END__ - 1; *p != (func_ptr) -1; p--)
     (*p) ();
 }
@@ -566,7 +566,7 @@ extern void __do_global_ctors (void);
 void
 __do_global_ctors (void)
 {
-  func_ptr *p;
+  const func_ptr *p;
 #if defined(USE_EH_FRAME_REGISTRY) || defined(JCR_SECTION_NAME)
   __do_global_ctors_1();
 #endif
@@ -578,6 +578,13 @@ __do_global_ctors (void)
 #error "What are you doing with crtstuff.c, then?"
 #endif
 
+#ifdef __riscos__
+static const char riscos_abi_version[]
+  __attribute__((used, section(".riscos.abi.version"), aligned(4))) =
+#include "config/arm/riscos-abi.h"
+  ;
+#endif
+
 #else /* ! CRT_BEGIN && ! CRT_END */
 #error "One of CRT_BEGIN or CRT_END must be defined."
 #endif
