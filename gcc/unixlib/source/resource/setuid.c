/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/resource/setuid.c,v $
 * $Date: 2001/01/29 15:10:20 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: setuid.c,v 1.2 2001/01/29 15:10:20 admin Exp $";
#endif

#include <unistd.h>
#include <unixlib/unix.h>

int
setuid (__uid_t uid)
{
  if (uid == __u->uid)
    return 0;
  if (uid == __u->euid)
    {
      __u->uid = uid;
      return 0;
    }
  return -1;
}
