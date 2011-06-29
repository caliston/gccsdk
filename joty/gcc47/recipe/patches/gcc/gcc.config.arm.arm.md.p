Index: gcc/config/arm/arm.md
===================================================================
--- gcc/config/arm/arm.md	(revision 175661)
+++ gcc/config/arm/arm.md	(working copy)
@@ -32,6 +32,7 @@
 (define_constants
   [(R0_REGNUM        0)		; First CORE register
    (R1_REGNUM	     1)		; Second CORE register
+   (SL_REGNUM	    10)		; Stack limit register (APCS-32 only)
    (IP_REGNUM	    12)		; Scratch register
    (SP_REGNUM	    13)		; Stack pointer
    (LR_REGNUM       14)		; Return address register
@@ -105,6 +106,8 @@
   UNSPEC_SYMBOL_OFFSET  ; The offset of the start of the symbol from
                         ; another symbolic address.
   UNSPEC_MEMORY_BARRIER ; Represent a memory barrier.
+  UNSPEC_STK            ; RISC OS port.
+  UNSPEC_CALL           ; RISC OS port.
 ])
 
 ;; UNSPEC_VOLATILE Usage:
@@ -8016,7 +8019,7 @@
       return thumb_call_via_reg (operands[0]);
     else if (operands[1] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%0\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%0\";
     else
       return \"bl\\t%__interwork_r11_call_via_%0\";
@@ -8128,7 +8131,7 @@
       return thumb_call_via_reg (operands[1]);
     else if (operands[2] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%1\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%1\";
     else
       return \"bl\\t%__interwork_r11_call_via_%1\";
@@ -10877,6 +10880,8 @@
 (include "ldmstm.md")
 ;; Load the FPA co-processor patterns
 (include "fpa.md")
+;; Load the RISC OS patterns
+(include "riscos.md")
 ;; Load the Maverick co-processor patterns
 (include "cirrus.md")
 ;; Vector bits common to IWMMXT and Neon
