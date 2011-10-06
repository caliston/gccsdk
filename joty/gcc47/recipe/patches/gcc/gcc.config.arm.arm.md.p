Index: gcc/config/arm/arm.md
===================================================================
--- gcc/config/arm/arm.md	(revision 179626)
+++ gcc/config/arm/arm.md	(working copy)
@@ -32,6 +32,7 @@
 (define_constants
   [(R0_REGNUM        0)		; First CORE register
    (R1_REGNUM	     1)		; Second CORE register
+   (SL_REGNUM	    10)		; Stack limit register (APCS-32 only)
    (IP_REGNUM	    12)		; Scratch register
    (SP_REGNUM	    13)		; Stack pointer
    (LR_REGNUM       14)		; Return address register
@@ -116,6 +117,8 @@
 			; unaligned locations, on architectures which support
 			; that.
   UNSPEC_UNALIGNED_STORE ; Same for str/strh.
+  UNSPEC_STK            ; RISC OS port.
+  UNSPEC_CALL           ; RISC OS port.
 ])
 
 ;; UNSPEC_VOLATILE Usage:
@@ -5695,7 +5698,7 @@
 	(mem:SI (plus:SI (match_operand:SI 1 "register_operand" "r")
 			 (unspec:SI [(match_operand:SI 2 "" "X")]
 				    UNSPEC_PIC_OFFSET))))]
-  "TARGET_VXWORKS_RTP && TARGET_ARM && flag_pic"
+  "(TARGET_VXWORKS_RTP && TARGET_ARM && flag_pic) || flag_pic == 2"
   "ldr%?\\t%0, [%1,%2]"
   [(set_attr "type" "load1")]
 )
@@ -8250,7 +8253,7 @@
       return thumb_call_via_reg (operands[0]);
     else if (operands[1] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%0\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%0\";
     else
       return \"bl\\t%__interwork_r11_call_via_%0\";
@@ -8362,7 +8365,7 @@
       return thumb_call_via_reg (operands[1]);
     else if (operands[2] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%1\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%1\";
     else
       return \"bl\\t%__interwork_r11_call_via_%1\";
@@ -11296,6 +11299,8 @@
 (include "ldmstm.md")
 ;; Load the FPA co-processor patterns
 (include "fpa.md")
+;; Load the RISC OS patterns
+(include "riscos.md")
 ;; Load the Maverick co-processor patterns
 (include "cirrus.md")
 ;; Vector bits common to IWMMXT and Neon
