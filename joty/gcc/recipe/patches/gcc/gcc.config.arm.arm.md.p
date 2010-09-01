Index: gcc/config/arm/arm.md
===================================================================
--- gcc/config/arm/arm.md	(revision 163743)
+++ gcc/config/arm/arm.md	(working copy)
@@ -31,6 +31,7 @@
 ;; Register numbers
 (define_constants
   [(R0_REGNUM        0)		; First CORE register
+   (SL_REGNUM	    10)		; Stack limit register (APCS-32 only)
    (IP_REGNUM	    12)		; Scratch register
    (SP_REGNUM	    13)		; Stack pointer
    (LR_REGNUM       14)		; Return address register
@@ -104,6 +105,8 @@
    (UNSPEC_SYMBOL_OFFSET 27) ; The offset of the start of the symbol from
                              ; another symbolic address.
    (UNSPEC_MEMORY_BARRIER 28) ; Represent a memory barrier.
+   (UNSPEC_STK 29)
+   (UNSPEC_CALL 30)
   ]
 )
 
@@ -7883,7 +7886,7 @@
       return thumb_call_via_reg (operands[0]);
     else if (operands[1] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%0\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%0\";
     else
       return \"bl\\t%__interwork_r11_call_via_%0\";
@@ -7995,7 +7998,7 @@
       return thumb_call_via_reg (operands[1]);
     else if (operands[2] == const0_rtx)
       return \"bl\\t%__interwork_call_via_%1\";
-    else if (frame_pointer_needed)
+    else if (arm_apcs_frame_needed ())
       return \"bl\\t%__interwork_r7_call_via_%1\";
     else
       return \"bl\\t%__interwork_r11_call_via_%1\";
@@ -10237,12 +10240,12 @@
     else
       {
 	int i;
-	char pattern[100];
+	char pattern[128];
 
 	if (TARGET_ARM)
-	    strcpy (pattern, \"stmfd\\t%m0!, {%1\");
+	  strcpy (pattern, \"stmfd\\t%m0!, {%1\");
 	else
-	    strcpy (pattern, \"push\\t{%1\");
+	  strcpy (pattern, \"push\\t{%1\");
 
 	for (i = 1; i < num_saves; i++)
 	  {
@@ -10703,6 +10706,8 @@
 (include "ldmstm.md")
 ;; Load the FPA co-processor patterns
 (include "fpa.md")
+;; Load the RISC OS patterns
+(include "riscos.md")
 ;; Load the Maverick co-processor patterns
 (include "cirrus.md")
 ;; Vector bits common to IWMMXT and Neon
