/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/unix/pipe.c,v $
 * $Date: 2004/10/17 16:24:45 $
 * $Revision: 1.6 $
 * $State: Exp $
 * $Author: joty $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: pipe.c,v 1.6 2004/10/17 16:24:45 joty Exp $";
#endif

#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include <unixlib/os.h>
#include <unixlib/dev.h>
#include <swis.h>
#include <unixlib/unix.h>

#include <unixlib/fd.h>
#include <pthread.h>

int
pipe (int *p)
{
#if __UNIXLIB_FEATURE_PIPEDEV
  struct __unixlib_fd *file_desc_0, *file_desc_1;
  int fd0, fd1;
  char file[32];
  int pcnt;

  PTHREAD_UNSAFE

  fd0 = __alloc_file_descriptor ();
  if (fd0 == -1)
    return -1;
  file_desc_0 = &__u->fd[fd0];
  /* Allocate the file descriptor.  */
  file_desc_0->__magic = _FDMAGIC;

  fd1 = __alloc_file_descriptor ();
  if (fd1 == -1)
    {
      /* Deallocate the first file descriptor.  */
      file_desc_0->__magic = 0;
      return -1;
    }

  file_desc_1 = &__u->fd[fd1];
  file_desc_1->__magic = _FDMAGIC;

  {
    char *s;
    int i;
    char num_buf[11];

    pcnt = i = __intenv ("UnixLib$pcnt");
    s = num_buf + sizeof (num_buf);
    *--s = '\0';
    do
      {
	*--s = (i % 10) + '0';
	i /= 10;
      }
    while (i != 0);

    strcpy (stpcpy (file, "/tmp/pipe"), s);
  }

  file_desc_0->fflag = O_RDWR | O_CREAT | O_TRUNC | O_PIPE;
  file_desc_0->dflag = file_desc_1->dflag = 0;

  {
    int handle;

    handle = (int) __funcall ((*(__dev[DEV_PIPE].open)), (file_desc_0, file, 0777));
    if (handle == -1)
      {
	/* Opening the pipes failed, so deallocate the file
	   descriptors and return.  */
	file_desc_0->__magic = file_desc_1->__magic = 0;
	return -1;
      }
    file_desc_0->device = file_desc_1->device = DEV_PIPE;
    file_desc_0->handle = file_desc_1->handle = (void *) handle;
  }

  {
    int regs[10];

    ++pcnt;
    regs[0] = (int) "UnixLib$pcnt";
    regs[1] = (int) &pcnt;
    regs[2] = 4;
    regs[3] = 0;
    regs[4] = 1;
    __os_swi (OS_SetVarVal, regs);
  }

  /* Set one file descriptor for read only and the other
     for write only.  */
  file_desc_0->fflag = O_RDONLY | O_UNLINKED | O_PIPE;
  file_desc_1->fflag = O_WRONLY | O_UNLINKED | O_PIPE;

  file_desc_0->pid = file_desc_1->pid = __u->pid;

  p[0] = fd0;
  p[1] = fd1;

  return 0;
#else /* !__UNIXLIB_FEATURE_PIPEDEV */
  return __set_errno (ENOSYS);
#endif
}
