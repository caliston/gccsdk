/* UnixLib fdopen() implementation.
   Copyright 2001-2010 UnixLib Developers.  */

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include <internal/unix.h>

/* #define DEBUG */
#ifdef DEBUG
#  include <sys/debug.h>
#endif

FILE *
fdopen (int fd, const char *mode)
{
#ifdef DEBUG
  debug_printf ("-- fdopen (fd=%d,mode=%s)\n", fd, mode);
#endif
  __io_mode m = __getmode (mode);
  if (! m.__bits.__read && ! m.__bits.__write)
    return NULL;

  /* Verify the FD is valid and allows the access 'mode' specifies.  */
  int dflags = getfd (fd)->fflag; /* dflags = fcntl (fd, F_GETFL); */
  if (dflags == -1)
    return NULL;

  /* Check the access mode.  */
  if (((dflags & O_ACCMODE) == O_RDONLY && !m.__bits.__read)
      || ((dflags & O_ACCMODE) == O_WRONLY && !m.__bits.__write))
    {
      __set_errno (EBADF);
      return NULL;
    }

  FILE *stream = __newstream ();
  if (stream == NULL)
    return NULL;

  stream->__mode = m;

  return __stream_init (fd, stream);
}
