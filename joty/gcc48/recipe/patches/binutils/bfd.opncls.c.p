--- bfd/opncls.c.orig	2011-06-27 10:41:00.000000000 +0200
+++ bfd/opncls.c	2011-11-21 19:42:18.586238070 +0100
@@ -28,6 +28,12 @@
 #include "libbfd.h"
 #include "libiberty.h"
 
+#ifdef __riscos__
+#include <limits.h>
+#include <kernel.h>
+#include <unixlib/local.h>
+#endif
+
 #ifndef S_IXUSR
 #define S_IXUSR 0100	/* Execute by owner.  */
 #endif
@@ -660,6 +666,23 @@ _maybe_make_executable (bfd * abfd)
 	  chmod (abfd->filename,
 		 (0777
 		  & (buf.st_mode | ((S_IXUSR | S_IXGRP | S_IXOTH) &~ mask))));
+
+#ifdef __riscos__
+	  /* When it is ELF format and we're running on RISC OS, set
+	     the 0xE1F filetype.  */
+	  if (bfd_get_flavour (abfd) == bfd_target_elf_flavour)
+	    {
+	      char robuf[_POSIX_PATH_MAX];
+	      /* Set filetype ELF.  */
+	      if (__riscosify_std (abfd->filename, 0, robuf, sizeof (robuf), NULL))
+		{
+		  _kernel_osfile_block bl;
+
+		  bl.load = 0xE1F; /* ELF binary */
+		  _kernel_osfile (18, robuf, &bl);
+		}
+	    }
+#endif
 	}
     }
 }