/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/unixlib/source/sys/c/os,v $
 * $Date: 1999/11/16 13:26:49 $
 * $Revision: 1.9 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: os,v 1.9 1999/11/16 13:26:49 admin Exp $";
#endif

#include <errno.h>
#include <string.h>

#include <sys/os.h>
#include <kernel.h>

_kernel_oserror the_error = { 0 };

void
__seterr (const _kernel_oserror * e)
{
  if (e)
    {
      char *q = the_error.errmess;
      int x = sizeof (the_error.errmess) - 1;
      const char *p;

      sys_errlist[EOPSYS] = the_error.errmess;
      /* Make sure the error message is stored safely for later
	 diagnostics.  */
      the_error.errnum = e->errnum;
      p = e->errmess;
      while ((*q++ = *p++) && --x != 0)
	;
      *q = '\0';
      (void) __set_errno (EOPSYS);
    }
}

/* Provide access to the full last OS error so can get OS error number.  */
_kernel_oserror *
_kernel_last_oserror (void)
{
  if (the_error.errnum)
    return &the_error;
  else
    return NULL;
}
