/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/time/times.c,v $
 * $Date: 2001/01/29 15:10:22 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: times.c,v 1.2 2001/01/29 15:10:22 admin Exp $";
#endif

/* Territory time support, written by Nick Burrett on 12 July 1997.  */

#include <time.h>
#include <sys/times.h>

clock_t
times (struct tms *tmsp)
{
  clock_t utime = clock ();
  if (tmsp)
    {
      tmsp->tms_utime = utime;	/* user time */
      tmsp->tms_stime = 0;	/* system time */
      tmsp->tms_cutime = 0;	/* user time, children */
      tmsp->tms_cstime = 0;	/* system time, children */
    }
  return utime;
}
