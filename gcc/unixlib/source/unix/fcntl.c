/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/unix/fcntl.c,v $
 * $Date: 2000/07/15 14:52:43 $
 * $Revision: 1.1.1.1 $
 * $State: Exp $
 * $Author: nick $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: fcntl.c,v 1.1.1.1 2000/07/15 14:52:43 nick Exp $";
#endif

#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <sys/unix.h>
#include <unixlib/fd.h>

int
fcntl (int fd, int cmd, ...)
{
  va_list ap;
  struct __unixlib_fd *file_desc;

  if (BADF (fd))
    return __set_errno (EBADF);

  file_desc = &__u->fd[fd];

  switch (cmd)
    {
    case F_DUPFD:
      {
	/* Duplicate the file descriptor.  */
	int duplicate_fd;

	va_start (ap, cmd);
	duplicate_fd = va_arg (ap, int);
	va_end (ap);

	/* Check the new file descriptor for validity.  */
	if ((unsigned int) duplicate_fd < MAXFD)
	  {
	    if (duplicate_fd == 0)
	      /* Allocate a new file descriptor.  */
	      duplicate_fd = __alloc_file_descriptor ();

	    if (duplicate_fd != -1)
	      {
		__u->fd[duplicate_fd] = __u->fd[fd];
		/* File descriptor flags aren't duplicated.  */
		__u->fd[duplicate_fd].dflag = 0;
	      }
	    return duplicate_fd;
	  }
	else
	  return __set_errno (EINVAL);
      }

    case F_GETFD:
      return file_desc->dflag;

    case F_SETFD:
      va_start (ap, cmd);
      file_desc->dflag = va_arg (ap, int);
      va_end (ap);
      return 0;

    case F_GETFL:
      return file_desc->fflag;

    case F_SETFL:
      va_start (ap, cmd);
      file_desc->fflag = va_arg (ap, int);
      va_end (ap);
      return 0;

    case F_GETUNL:
      return (file_desc->fflag & O_UNLINKED) ? 1 : 0;

    case F_SETUNL:
      {
	int arg;

	va_start (ap, cmd);
	arg = va_arg (ap, int);
	va_end (ap);

	if (arg)
	  file_desc->fflag |= O_UNLINKED;
	else
	  file_desc->fflag &= ~O_UNLINKED;
	return 0;
      }
    }

  return __set_errno (EINVAL);
}
