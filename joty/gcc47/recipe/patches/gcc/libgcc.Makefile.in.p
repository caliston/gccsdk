Index: libgcc/Makefile.in
===================================================================
--- libgcc/Makefile.in	(revision 177604)
+++ libgcc/Makefile.in	(working copy)
@@ -249,6 +249,10 @@
 compile_deps = -MT $@ -MD -MP -MF $(basename $@).dep
 gcc_compile = $(gcc_compile_bare) -o $@ $(compile_deps)
 gcc_s_compile = $(gcc_compile) -DSHARED
+  
+ifeq ($(host_noncanonical),arm-unknown-riscos)
+  gcc_s_compile += -fPIC
+endif
 
 objects = $(filter %$(objext),$^)
 
