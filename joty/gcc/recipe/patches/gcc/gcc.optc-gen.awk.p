Index: gcc/optc-gen.awk
===================================================================
--- gcc/optc-gen.awk	(revision 161055)
+++ gcc/optc-gen.awk	(working copy)
@@ -109,6 +109,8 @@
 	print "/* Set by -" opts[i] "."
 	print "   " help[i] "  */"
 	print var_type(flags[i]) name init ";"
+	if (flag_set_p("Explicit", flags[i]))
+		print var_type(flags[i]) name "_explicit;"
 	if (gcc_driver == 1)
 		print "#endif /* GCC_DRIVER */"
 	print ""
