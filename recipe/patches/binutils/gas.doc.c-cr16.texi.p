--- gas/doc/c-cr16.texi.orig	2015-03-01 21:14:10.627314517 +0100
+++ gas/doc/c-cr16.texi	2015-03-01 21:18:16.507313785 +0100
@@ -43,26 +43,33 @@ Operand expression type qualifier is an
 CR16 target operand qualifiers and its size (in bits):
 
 @table @samp
-@item Immediate Operand
-- s ---- 4 bits
-@item 
-- m ---- 16 bits, for movb and movw instructions.
-@item 
-- m ---- 20 bits, movd instructions.
-@item 
-- l ---- 32 bits
-
-@item Absolute Operand
-- s ---- Illegal specifier for this operand.
-@item  
-- m ---- 20 bits, movd instructions.
-
-@item Displacement Operand
-- s ---- 8 bits
-@item
-- m ---- 16 bits
-@item 
-- l ---- 24 bits
+@item Immediate Operand: s
+4 bits.
+
+@item Immediate Operand: m
+16 bits, for movb and movw instructions.
+
+@item Immediate Operand: m
+20 bits, movd instructions.
+
+@item Immediate Operand: l
+32 bits.
+
+@item Absolute Operand: s
+Illegal specifier for this operand.
+
+@item Absolute Operand: m
+20 bits, movd instructions.
+
+@item Displacement Operand: s
+8 bits.
+
+@item Displacement Operand: m
+16 bits.
+
+@item Displacement Operand: l
+24 bits.
+
 @end table
 
 For example:
