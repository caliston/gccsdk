Index: Makefile.tpl
===================================================================
--- Makefile.tpl	(revision 97921)
+++ Makefile.tpl	(working copy)
@@ -1459,7 +1459,7 @@
 
 
 [+ FOR lang_env_dependencies +]
-configure-target-[+module+]: maybe-all-target-newlib maybe-all-target-libgloss
+configure-target-[+module+]:  maybe-all-target-libunixlib maybe-all-target-newlib maybe-all-target-libgloss
 [+ IF cxx +]configure-target-[+module+]: maybe-all-target-libstdc++-v3
 [+ ENDIF cxx +][+ ENDFOR lang_env_dependencies +]
 
