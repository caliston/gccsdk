Index: gcc/config/arm/arm.md
===================================================================
--- gcc/config/arm/arm.md	(revision 161568)
+++ gcc/config/arm/arm.md	(working copy)
@@ -31,6 +31,7 @@
 ;; Register numbers
 (define_constants
   [(R0_REGNUM        0)		; First CORE register
+   (SL_REGNUM	    10)		; Stack limit register (APCS-32 only)
    (IP_REGNUM	    12)		; Scratch register
    (SP_REGNUM	    13)		; Stack pointer
    (LR_REGNUM       14)		; Return address register
@@ -103,6 +104,8 @@
    (UNSPEC_RBIT 26)       ; rbit operation.
    (UNSPEC_SYMBOL_OFFSET 27) ; The offset of the start of the symbol from
                              ; another symbolic address.
+   (UNSPEC_STK 28)
+   (UNSPEC_CALL 29)
   ]
 )
 
@@ -8537,7 +8540,7 @@
       return thumb_call_via_reg (operands[0]);
     else if (operands[1] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%0\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%0\";
     else
       return \"bl\\t%__interwork_r11_call_via_%0\";
@@ -8649,7 +8652,7 @@
       return thumb_call_via_reg (operands[1]);
     else if (operands[2] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%1\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%1\";
     else
       return \"bl\\t%__interwork_r11_call_via_%1\";
@@ -11345,6 +11348,8 @@
 
 ;; Load the FPA co-processor patterns
 (include "fpa.md")
+;; Load the RISC OS patterns
+(include "riscos.md")
 ;; Load the Maverick co-processor patterns
 (include "cirrus.md")
 ;; Vector bits common to IWMMXT and Neon
