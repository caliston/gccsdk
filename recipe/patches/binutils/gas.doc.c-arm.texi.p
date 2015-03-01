--- gas/doc/c-arm.texi.orig	2010-09-23 17:52:18.000000000 +0200
+++ gas/doc/c-arm.texi	2015-03-01 21:14:10.623314517 +0100
@@ -376,29 +376,29 @@ ARM and THUMB instructions had their own
 @code{unified} syntax, which can be selected via the @code{.syntax}
 directive, and has the following main features:
 
-@table @bullet
-@item
+@table @code
+@item 1
 Immediate operands do not require a @code{#} prefix.
 
-@item
+@item 2
 The @code{IT} instruction may appear, and if it does it is validated
 against subsequent conditional affixes.  In ARM mode it does not
 generate machine code, in THUMB mode it does.
 
-@item
+@item 3
 For ARM instructions the conditional affixes always appear at the end
 of the instruction.  For THUMB instructions conditional affixes can be
 used, but only inside the scope of an @code{IT} instruction.
 
-@item
+@item 4
 All of the instructions new to the V6T2 architecture (and later) are
 available.  (Only a few such instructions can be written in the
 @code{divided} syntax).
 
-@item
+@item 5
 The @code{.N} and @code{.W} suffixes are recognized and honored.
 
-@item
+@item 6
 All instructions set the flags if and only if they have an @code{s}
 affix.
 @end table
@@ -433,28 +433,6 @@ Either @samp{#} or @samp{$} can be used
 @cindex register names, ARM
 *TODO* Explain about ARM register naming, and the predefined names.
 
-@node ARM-Neon-Alignment
-@subsection NEON Alignment Specifiers
-
-@cindex alignment for NEON instructions
-Some NEON load/store instructions allow an optional address
-alignment qualifier.
-The ARM documentation specifies that this is indicated by
-@samp{@@ @var{align}}. However GAS already interprets
-the @samp{@@} character as a "line comment" start,
-so @samp{: @var{align}} is used instead.  For example:
-
-@smallexample
-        vld1.8 @{q0@}, [r0, :128]
-@end smallexample
-
-@node ARM Floating Point
-@section Floating Point
-
-@cindex floating point, ARM (@sc{ieee})
-@cindex ARM floating point (@sc{ieee})
-The ARM family uses @sc{ieee} floating-point numbers.
-
 @node ARM-Relocations
 @subsection ARM relocation generation
 
@@ -497,6 +475,28 @@ respectively.  For example to load the 3
         MOVT r0, #:upper16:foo
 @end smallexample
 
+@node ARM-Neon-Alignment
+@subsection NEON Alignment Specifiers
+
+@cindex alignment for NEON instructions
+Some NEON load/store instructions allow an optional address
+alignment qualifier.
+The ARM documentation specifies that this is indicated by
+@samp{@@ @var{align}}. However GAS already interprets
+the @samp{@@} character as a "line comment" start,
+so @samp{: @var{align}} is used instead.  For example:
+
+@smallexample
+        vld1.8 @{q0@}, [r0, :128]
+@end smallexample
+
+@node ARM Floating Point
+@section Floating Point
+
+@cindex floating point, ARM (@sc{ieee})
+@cindex ARM floating point (@sc{ieee})
+The ARM family uses @sc{ieee} floating-point numbers.
+
 @node ARM Directives
 @section ARM Machine Directives
 
