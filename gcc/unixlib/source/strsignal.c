/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/strsignal.c,v $
 * $Date: 2002/09/24 11:51:26 $
 * $Revision: 1.2.2.1 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: strsignal.c,v 1.2.2.1 2002/09/24 11:51:26 admin Exp $";
#endif

#include <signal.h>
#include <stdio.h>
#include <string.h>


/* Return a string describing the meaning of the signal number SIGNUM.  */
char *
strsignal (int signum)
{
  if (signum < 0 || signum >= NSIG)
    {
      static char unknown_signal[] = "Unknown signal 00000000000";

      sprintf (unknown_signal, "Unknown signal %d", signum);
      return unknown_signal;
    }

  return (char *) sys_siglist[signum];
}
