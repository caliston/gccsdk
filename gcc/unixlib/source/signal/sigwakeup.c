/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/signal/sigwakeup.c,v $
 * $Date: 2001/01/29 15:10:21 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: sigwakeup.c,v 1.2 2001/01/29 15:10:21 admin Exp $";
#endif

/* Written by Nick Burrett, 26 August 1996.  */

#include <unixlib/unix.h>

/* Wake a task up.  */
void
sigwakeup (void)
{
  __u->sleeping = 0;
}
