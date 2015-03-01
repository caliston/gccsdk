--- gas/doc/c-tic54x.texi.orig	2015-03-01 21:14:10.627314517 +0100
+++ gas/doc/c-tic54x.texi	2015-03-01 21:41:06.559309709 +0100
@@ -108,7 +108,7 @@ In this example, x is replaced with SYM2
 is replaced with x.  At this point, x has already been encountered
 and the substitution stops.
 
-@smallexample @code
+@smallexample
  .asg   "x",SYM1 
  .asg   "SYM1",SYM2
  .asg   "SYM2",x
@@ -344,7 +344,7 @@ Assign @var{name} the string @var{string
 performed on @var{string} before assignment.
 
 @cindex @code{eval} directive, TIC54X
-@itemx .eval @var{string}, @var{name}
+@item .eval @var{string}, @var{name}
 Evaluate the contents of string @var{string} and assign the result as a
 string to the subsym @var{name}.  String replacement is performed on
 @var{string} before assignment. 
