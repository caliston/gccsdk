/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/sys/child.c,v $
 * $Date: 2001/01/29 15:10:21 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: child.c,v 1.2 2001/01/29 15:10:21 admin Exp $";
#endif

#include <unixlib/unix.h>
#include <sys/wait.h>

/* This is a utility function used by fork and vfork. It
   searches through the number of children this process
   can have and returns an index to a child suitable for
   re-birth.

   A child applicable for re-birth could either be one that
   has terminated or one that was never born in the first
   place.

   An unborn child will have no memory allocated to it.  */

int
__find_free_child (void)
{
  int i;

  for (i = 0; i < CHILD_MAX; i++)
    {
      /* A terminated child will be anything that hasn't stopped.  */
      if (!__u->child[i].status.stopped)
	return i;
    }
  return -1;
}
