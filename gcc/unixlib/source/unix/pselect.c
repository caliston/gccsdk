/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/unix/pselect.c,v $
 * $Date: 2001/01/29 15:10:22 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: pselect.c,v 1.2 2001/01/29 15:10:22 admin Exp $";
#endif

#include <time.h>
#include <sys/time.h>
#include <sys/select.h>

int pselect (int nfds, fd_set *readfds, fd_set *writefds,
    	     fd_set *exceptfds, struct timespec *spec_timeout)
{
  struct timeval val_timeout;

  /* Convert the nanoseconds resolution into milliseconds.  */
  TIMESPEC_TO_TIMEVAL (&val_timeout, spec_timeout);
  return select (nfds, readfds, writefds, exceptfds, &val_timeout);
}
