/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/netlib/sendto.c,v $
 * $Date: 2005/03/04 20:59:05 $
 * $Revision: 1.6 $
 * $State: Exp $
 * $Author: alex $
 *
 * (c) Copyright 1995 Sergio Monesi
 ***************************************************************************/

#include <unixlib/unix.h>
#include <sys/socket.h>
#include <unixlib/fd.h>
#include <unixlib/local.h>
#include <pthread.h>

int
sendto (int s, const void *msg, size_t len, int flags,
	const struct sockaddr *to, socklen_t tolen)
{
  PTHREAD_UNSAFE_CANCELLATION

/*  printf("U! sendto: fd=%d, realsocket=%d\n",s,(__u->file+s)->r[0]); */
  if (__socket_valid (s) == -1)
    return -1;

  return _sendto ((int)(getfd (s)->devicehandle->handle), msg, len, flags, to, tolen);
}
