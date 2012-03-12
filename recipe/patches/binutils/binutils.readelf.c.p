--- binutils/readelf.c.orig	2012-03-11 16:01:01.000000000 +0000
+++ binutils/readelf.c	2012-03-11 15:59:37.000000000 +0000
@@ -1739,6 +1739,12 @@ get_dynamic_type (unsigned long type)
 	    case EM_IA_64:
 	      result = get_ia64_dynamic_type (type);
 	      break;
+	    case EM_ARM:
+	      if (type == DT_RISCOS_PIC)
+		return "RISCOS_PIC";
+	      else if (type == DT_RISCOS_GCC_DIR)
+		return "RISCOS_GCC_DIR";
+	      /* Fall through.  */
 	    default:
 	      result = NULL;
 	      break;
