Index: gcc/doc/invoke.texi
===================================================================
--- gcc/doc/invoke.texi	(revision 206264)
+++ gcc/doc/invoke.texi	(working copy)
@@ -472,6 +472,7 @@
 @gccoptlist{-mapcs-frame  -mno-apcs-frame @gol
 -mabi=@var{name} @gol
 -mapcs-stack-check  -mno-apcs-stack-check @gol
+-mmodule  -mno-module @gol
 -mapcs-float  -mno-apcs-float @gol
 -mapcs-reentrant  -mno-apcs-reentrant @gol
 -msched-prolog  -mno-sched-prolog @gol
@@ -10550,7 +10551,8 @@
 @item -mabi=@var{name}
 @opindex mabi
 Generate code for the specified ABI@.  Permissible values are: @samp{apcs-gnu},
-@samp{atpcs}, @samp{aapcs}, @samp{aapcs-linux} and @samp{iwmmxt}.
+@samp{apcs-32}, @samp{atpcs}, @samp{aapcs}, @samp{aapcs-linux} and
+@samp{iwmmxt}.
 
 @item -mapcs-frame
 @opindex mapcs-frame
@@ -10564,8 +10566,6 @@
 @opindex mapcs
 This is a synonym for @option{-mapcs-frame}.
 
-@ignore
-@c not currently implemented
 @item -mapcs-stack-check
 @opindex mapcs-stack-check
 Generate code to check the amount of stack space available upon entry to
@@ -10574,9 +10574,16 @@
 @samp{__rt_stkovf_split_small} or @samp{__rt_stkovf_split_big} will be
 called, depending upon the amount of stack space required.  The runtime
 system is required to provide these functions.  The default is
-@option{-mno-apcs-stack-check}, since this produces smaller code.
+@option{-mno-apcs-stack-check}, since this produces smaller code.  However,
+the APCS-32@ ABI has @option{-mapcs-stack-check} as default except when
+module code is generated with @option{-mmodule}.
 
-@c not currently implemented
+@item -mmodule
+@opindex mmodule
+Generate code suited for building RISC OS modules.  All writable data
+are accessed via an offset determined by the value at R10-536.  This is
+only supported for APCS-32@ ABI.  The default is @option{-mno-module}.
+
 @item -mapcs-float
 @opindex mapcs-float
 Pass floating-point arguments using the floating-point registers.  This is
@@ -10586,6 +10593,7 @@
 @option{-mno-apcs-float}, since integer only code is slightly increased in
 size if @option{-mapcs-float} is used.
 
+@ignore
 @c not currently implemented
 @item -mapcs-reentrant
 @opindex mapcs-reentrant
