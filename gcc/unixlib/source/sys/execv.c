/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/sys/execv.c,v $
 * $Date: 2002/09/24 12:04:05 $
 * $Revision: 1.2.2.1 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: execv.c,v 1.2.2.1 2002/09/24 12:04:05 admin Exp $";
#endif

#include <unistd.h>

/* Execute path with arguments argv and environment from 'environ'.  */
int
execv (const char *path, char *const argv[])
{
  return execve (path, argv, environ);
}
