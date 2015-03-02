--- gas/doc/c-tic54x.texi.orig	2015-03-02 23:23:33.217905083 +0100
+++ gas/doc/c-tic54x.texi	2015-03-02 23:23:20.509904922 +0100
@@ -108,7 +108,7 @@ In this example, x is replaced with SYM2
 is replaced with x.  At this point, x has already been encountered
 and the substitution stops.
 
-@smallexample @code
+@smallexample
  .asg   "x",SYM1 
  .asg   "SYM1",SYM2
  .asg   "SYM2",x
@@ -125,14 +125,14 @@ Substitution may be forced in situations
 ambiguous by placing colons on either side of the subsym.  The following
 code: 
 
-@smallexample @code
+@smallexample
  .eval  "10",x
 LAB:X:  add     #x, a
 @end smallexample
 
 When assembled becomes:
 
-@smallexample @code
+@smallexample
 LAB10  add     #10, a
 @end smallexample
 
@@ -308,7 +308,7 @@ The @code{LDX} pseudo-op is provided for
 of a label or address.  For example, if an address @code{_label} resides
 in extended program memory, the value of @code{_label} may be loaded as
 follows:
-@smallexample @code
+@smallexample
  ldx     #_label,16,a    ; loads extended bits of _label
  or      #_label,a       ; loads lower 16 bits of _label
  bacc    a               ; full address is in accumulator A
@@ -344,7 +344,7 @@ Assign @var{name} the string @var{string
 performed on @var{string} before assignment.
 
 @cindex @code{eval} directive, TIC54X
-@itemx .eval @var{string}, @var{name}
+@item .eval @var{string}, @var{name}
 Evaluate the contents of string @var{string} and assign the result as a
 string to the subsym @var{name}.  String replacement is performed on
 @var{string} before assignment. 
