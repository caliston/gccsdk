/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/resource/seteuid.c,v $
 * $Date: 2000/07/15 14:52:28 $
 * $Revision: 1.1.1.1 $
 * $State: Exp $
 * $Author: nick $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: seteuid.c,v 1.1.1.1 2000/07/15 14:52:28 nick Exp $";
#endif

#include <unistd.h>
#include <sys/unix.h>

int
seteuid (__uid_t uid)
{
  if (uid == __u->euid)
    return 0;
  if (uid == __u->uid)
    {
      __u->euid = uid;
      return 0;
    }
  return -1;
}
