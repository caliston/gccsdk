Index: Makefile.tpl
===================================================================
--- Makefile.tpl	(revision 187669)
+++ Makefile.tpl	(working copy)
@@ -1844,7 +1844,7 @@
 @endif gcc-no-bootstrap
 
 [+ FOR target_modules +][+ IF (not (lang-dep "no_c")) +]
-configure-target-[+module+]: maybe-all-target-newlib maybe-all-target-libgloss[+
+configure-target-[+module+]: maybe-all-target-libunixlib maybe-all-target-newlib maybe-all-target-libgloss[+
   ENDIF +][+ IF (lang-dep "cxx") +]
 configure-target-[+module+]: maybe-all-target-libstdc++-v3[+
   ENDIF +]
