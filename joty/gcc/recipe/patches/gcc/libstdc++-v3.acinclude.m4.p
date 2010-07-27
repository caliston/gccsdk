Index: libstdc++-v3/acinclude.m4
===================================================================
--- libstdc++-v3/acinclude.m4	(revision 162611)
+++ libstdc++-v3/acinclude.m4	(working copy)
@@ -1655,7 +1655,7 @@
 
 m4_pushdef([n_syserr], [1])dnl
 m4_foreach([syserr], [EOWNERDEAD, ENOTRECOVERABLE, ENOLINK, EPROTO, ENODATA,
-		      ENOSR, ENOSTR, ETIME, EBADMSG, ECANCELED,
+		      ENOMSG, ENOSR, ENOSTR, ETIME, EBADMSG, ECANCELED,
 		      EOVERFLOW, ENOTSUP, EIDRM, ETXTBSY],
 [m4_pushdef([SYSERR], m4_toupper(syserr))dnl
 AC_MSG_CHECKING([for syserr])
