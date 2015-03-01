--- ld/ld.texinfo.orig	2015-03-01 20:45:50.631319576 +0100
+++ ld/ld.texinfo	2015-03-01 20:45:40.655319605 +0100
@@ -141,12 +141,12 @@ in the section entitled ``GNU Free Docum
 @ifset ARM
 * ARM::				ld and the ARM family
 @end ifset
-@ifset HPPA
-* HPPA ELF32::                  ld and HPPA 32-bit ELF
-@end ifset
 @ifset M68HC11
 * M68HC11/68HC12::              ld and the Motorola 68HC11 and 68HC12 families
 @end ifset
+@ifset HPPA
+* HPPA ELF32::                  ld and HPPA 32-bit ELF
+@end ifset
 @ifset M68K
 * M68K::                        ld and Motorola 68K family
 @end ifset
@@ -5877,6 +5877,9 @@ functionality are not listed.
 @ifset I960
 * i960::                        @command{ld} and the Intel 960 family
 @end ifset
+@ifset M68HC11
+* M68HC11/68HC12::		@code{ld} and the Motorola 68HC11 and 68HC12 families
+@end ifset
 @ifset ARM
 * ARM::				@command{ld} and the ARM family
 @end ifset
@@ -5892,9 +5895,6 @@ functionality are not listed.
 @ifset MSP430
 * MSP430::			@command{ld} and MSP430
 @end ifset
-@ifset M68HC11
-* M68HC11/68HC12::		@code{ld} and the Motorola 68HC11 and 68HC12 families
-@end ifset
 @ifset POWERPC
 * PowerPC ELF32::		@command{ld} and PowerPC 32-bit ELF Support
 @end ifset
@@ -7682,7 +7682,7 @@ If you have more than one @code{SECT} st
 @printindex cp
 
 @tex
-% I think something like @colophon should be in texinfo.  In the
+% I think something like @@colophon should be in texinfo.  In the
 % meantime:
 \long\def\colophon{\hbox to0pt{}\vfill
 \centerline{The body of this manual is set in}
@@ -7693,7 +7693,7 @@ If you have more than one @code{SECT} st
 \centerline{{\sl\fontname\tensl\/}}
 \centerline{are used for emphasis.}\vfill}
 \page\colophon
-% Blame: doc@cygnus.com, 28mar91.
+% Blame: doc@@cygnus.com, 28mar91.
 @end tex
 
 @bye
