/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/unix/chown.c,v $
 * $Date: 2001/01/29 15:10:22 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: chown.c,v 1.2 2001/01/29 15:10:22 admin Exp $";
#endif

#include <errno.h>
#include <unistd.h>
#include <sys/types.h>

#define IGNORE(x) x = x

int
chown (const char *file, uid_t owner, gid_t group)
{
  IGNORE (file);
  IGNORE (owner);
  IGNORE (group);
  return __set_errno (ENOSYS);
}
