/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/resource/getpgrp.c,v $
 * $Date: 2001/01/29 15:10:20 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: getpgrp.c,v 1.2 2001/01/29 15:10:20 admin Exp $";
#endif

#include <unistd.h>
#include <unixlib/unix.h>

__pid_t
getpgrp (void)
{
  return (__u->pgrp);
}
