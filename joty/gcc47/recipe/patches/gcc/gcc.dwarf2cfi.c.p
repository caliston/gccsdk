Index: gcc/dwarf2cfi.c
===================================================================
--- gcc/dwarf2cfi.c	(revision 176117)
+++ gcc/dwarf2cfi.c	(working copy)
@@ -1662,7 +1662,9 @@
 	      /* Rule 3 */
 	      /* Either setting the FP from an offset of the SP,
 		 or adjusting the FP */
+#ifndef TARGET_RISCOSELF
 	      gcc_assert (frame_pointer_needed);
+#endif
 
 	      gcc_assert (REG_P (XEXP (src, 0))
 			  && (unsigned) REGNO (XEXP (src, 0)) == cfa.reg
@@ -1711,6 +1713,14 @@
 		  cfa_temp.reg = REGNO (dest);
 		  cfa_temp.offset = INTVAL (XEXP (src, 1));
 		}
+
+	      /* Rule XX */
+	      else if (GET_CODE (src) == PLUS
+		       && GET_CODE (XEXP (src, 1)) == CONST_INT)
+		{
+		  cfa_temp.reg = REGNO (dest);
+		  cfa_temp.offset = INTVAL (XEXP (src, 1));
+		}
 	      else
 		gcc_unreachable ();
 	    }
