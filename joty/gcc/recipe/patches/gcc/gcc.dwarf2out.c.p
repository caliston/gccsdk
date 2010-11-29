Index: gcc/dwarf2out.c
===================================================================
--- gcc/dwarf2out.c	(revision 167269)
+++ gcc/dwarf2out.c	(working copy)
@@ -2452,7 +2452,9 @@
 	      /* Rule 3 */
 	      /* Either setting the FP from an offset of the SP,
 		 or adjusting the FP */
+#ifndef TARGET_RISCOSELF
 	      gcc_assert (frame_pointer_needed);
+#endif
 
 	      gcc_assert (REG_P (XEXP (src, 0))
 			  && (unsigned) REGNO (XEXP (src, 0)) == cfa.reg
@@ -2501,6 +2503,13 @@
 		  cfa_temp.reg = REGNO (dest);
 		  cfa_temp.offset = INTVAL (XEXP (src, 1));
 		}
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
@@ -17266,12 +17275,14 @@
       elim = XEXP (elim, 0);
     }
 
+#ifndef TARGET_RISCOSELF
   gcc_assert ((SUPPORTS_STACK_ALIGNMENT
 	       && (elim == hard_frame_pointer_rtx
 		   || elim == stack_pointer_rtx))
 	      || elim == (frame_pointer_needed
 			  ? hard_frame_pointer_rtx
 			  : stack_pointer_rtx));
+#endif
 
   frame_pointer_fb_offset = -offset;
 }
