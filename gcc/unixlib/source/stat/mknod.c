/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/unix/link.c,v $
 * $Date: 2002/01/31 14:32:04 $
 * $Revision: 1.2.2.1 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: link.c,v 1.2.2.1 2002/01/31 14:32:04 admin Exp $";
#endif

#include <errno.h>
#include <sys/stat.h>

int
mknod (const char *path, mode_t mode, dev_t dev)
{
  path = path;
  mode = mode;
  dev = dev;

  return __set_errno (ENOSYS);
}
