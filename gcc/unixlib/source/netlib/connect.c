/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/netlib/connect.c,v $
 * $Date: 2002/08/05 09:12:59 $
 * $Revision: 1.2.2.2 $
 * $State: Exp $
 * $Author: admin $
 *
 * (c) Copyright 1995 Sergio Monesi
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: connect.c,v 1.2.2.2 2002/08/05 09:12:59 admin Exp $";
#endif

#include <unixlib/unix.h>
#include <sys/socket.h>
#include <unixlib/fd.h>
#include <unixlib/local.h>

int
connect (int s, const struct sockaddr *name, socklen_t namelen)
{
  if (__socket_valid (s) == -1)
    return -1;

  /* printf("U! connect: fd=%d, realsocket=%d\n", s, __u->fd[s].handle); */
  return _connect ((int)__u->fd[s].handle, name, namelen);
}
