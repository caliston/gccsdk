/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/resource/geteuid.c,v $
 * $Date: 2001/01/29 15:10:20 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: geteuid.c,v 1.2 2001/01/29 15:10:20 admin Exp $";
#endif

#include <unistd.h>
#include <unixlib/unix.h>

__uid_t
geteuid (void)
{
  return __u->euid;
}
