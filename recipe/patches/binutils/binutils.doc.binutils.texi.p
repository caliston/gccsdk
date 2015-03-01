--- binutils/doc/binutils.texi.orig	2010-10-29 14:10:32.000000000 +0200
+++ binutils/doc/binutils.texi	2015-03-01 20:42:50.235320112 +0100
@@ -147,18 +147,18 @@ in the section entitled ``GNU Free Docum
 * objcopy::			Copy and translate object files
 * objdump::                     Display information from object files
 * ranlib::                      Generate index to archive contents
-* readelf::                     Display the contents of ELF format files
 * size::                        List section sizes and total size
 * strings::                     List printable strings from files
 * strip::                       Discard symbols
-* elfedit::                     Update the ELF header of ELF files
 * c++filt::			Filter to demangle encoded C++ symbols
 * cxxfilt: c++filt.             MS-DOS name for c++filt
 * addr2line::			Convert addresses to file and line
 * nlmconv::                     Converts object code into an NLM
-* windres::			Manipulate Windows resources
 * windmc::			Generator for Windows message resources
+* windres::			Manipulate Windows resources
 * dlltool::			Create files needed to build and use DLLs
+* readelf::                     Display the contents of ELF format files
+* elfedit::                     Update the ELF header of ELF files
 * Common Options::              Command-line options for all utilities
 * Selecting the Target System:: How these utilities determine the target
 * Reporting Bugs::              Reporting Bugs
@@ -2765,7 +2765,7 @@ the Info entries for @file{binutils}.
 @c man end
 @end ignore
 
-@node c++filt, addr2line, elfedit, Top
+@node c++filt, addr2line, strip, Top
 @chapter c++filt
 
 @kindex c++filt
@@ -4188,28 +4188,28 @@ equivalent. At least one of the @option{
 
 @table @env
 
-@itemx --input-mach=@var{machine}
+@item --input-mach=@var{machine}
 Set the matching input ELF machine type to @var{machine}.  If
 @option{--input-mach} isn't specified, it will match any ELF
 machine types.
 
 The supported ELF machine types are, @var{L1OM} and @var{x86-64}.
 
-@itemx --output-mach=@var{machine}
+@item --output-mach=@var{machine}
 Change the ELF machine type in the ELF header to @var{machine}.  The
 supported ELF machine types are the same as @option{--input-mach}.
 
-@itemx --input-type=@var{type}
+@item --input-type=@var{type}
 Set the matching input ELF file type to @var{type}.  If
 @option{--input-type} isn't specified, it will match any ELF file types.
 
 The supported ELF file types are, @var{rel}, @var{exec} and @var{dyn}.
 
-@itemx --output-type=@var{type}
+@item --output-type=@var{type}
 Change the ELF file type in the ELF header to @var{type}.  The
 supported ELF types are the same as @option{--input-type}.
 
-@itemx --input-osabi=@var{osabi}
+@item --input-osabi=@var{osabi}
 Set the matching input ELF file OSABI to @var{osbi}.  If
 @option{--input-osabi} isn't specified, it will match any ELF OSABIs.
 
@@ -4218,7 +4218,7 @@ The supported ELF OSABIs are, @var{none}
 @var{FreeBSD}, @var{TRU64}, @var{Modesto}, @var{OpenBSD}, @var{OpenVMS},
 @var{NSK}, @var{AROS} and @var{FenixOS}.
 
-@itemx --output-osabi=@var{osabi}
+@item --output-osabi=@var{osabi}
 Change the ELF OSABI in the ELF header to @var{type}.  The
 supported ELF OSABI are the same as @option{--input-osabi}.
 
