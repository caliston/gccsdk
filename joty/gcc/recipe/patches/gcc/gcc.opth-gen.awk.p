Index: gcc/opth-gen.awk
===================================================================
--- gcc/opth-gen.awk	(revision 164393)
+++ gcc/opth-gen.awk	(working copy)
@@ -94,6 +94,12 @@
 
 	var_seen[name] = 1;
 	print "extern " var_type(flags[i]) name ";"
+
+	if (flag_set_p("Explicit", flags[i]) && !(name in var_explicit)) {
+	    var_explicit[name] = 1;
+	    print "extern " var_type(flags[i]) name "_explicit;";
+	}
+
 }
 print ""
 
