Index: gcc/optc-gen.awk
===================================================================
--- gcc/optc-gen.awk	(revision 164393)
+++ gcc/optc-gen.awk	(working copy)
@@ -110,6 +110,8 @@
 	print "/* Set by -" opts[i] "."
 	print "   " help[i] "  */"
 	print var_type(flags[i]) name init ";"
+	if (flag_set_p("Explicit", flags[i]))
+		print var_type(flags[i]) name "_explicit;"
 	print ""
 
 	var_seen[name] = 1;
