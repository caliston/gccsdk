/* __flsbuf ()
 * Copyright (c) 2000-2008 UnixLib Developers
 */

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#include <pthread.h>
#include <internal/unix.h>

/* #define DEBUG */
#ifdef DEBUG
#  include <sys/debug.h>
#endif

/* __flsbuf(EOF, f) flushes output without adding c.  */
int
__flsbuf (int c, FILE *stream)
{
  unsigned char *buffer;

  PTHREAD_UNSAFE

  if (ferror (stream))
    return EOF;

#ifdef DEBUG
  debug_printf ("-- __flsbuf(%d): ", stream->fd);
#endif

  if (stream->__pushedback)
    {
      /* Discard the char pushed back by ungetc.  */
      stream->i_cnt = stream->__pushedi_cnt;
      stream->__pushedback = 0;
    }

  if (stream->o_base != NULL)
    {
      int to_write, written;

      to_write = stream->o_ptr - stream->o_base;
#ifdef DEBUG
      debug_printf ("to_write=%d\n", to_write);
#endif
      /* Skip write if 0 characters to write. Keeps perl happy, consistent
         with BSD.  */
      written = to_write ? write (stream->fd, stream->o_base, to_write) : 0;
      if (written < to_write)
        {
          stream->__error = 1;
          return EOF;
        }
      stream->__offset += to_write;
      stream->o_cnt = stream->__bufsize;
      stream->o_ptr = stream->o_base;
    }
#ifdef DEBUG
  else
    debug_printf ("nothing to write\n");
#endif

  if (c == EOF)
    return 0;

  /* Write out the last character.  */
  buffer = (unsigned char *)&c;
  if (write (stream->fd, buffer, 1) < 1)
    {
      stream->__error = 1;
      return EOF;
    }
  stream->__offset ++;

  return c;
}