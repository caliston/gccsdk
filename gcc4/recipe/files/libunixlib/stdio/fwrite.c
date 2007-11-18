/* UnixLib fwrite() implementation.
   Copyright 2001-2007 UnixLib Developers.  */

/* #define DEBUG */

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <unixlib/unix.h>

#ifdef DEBUG
#include <unixlib/os.h>
#endif

/* Return number of objects written.  */
size_t
fwrite (const void *data, size_t size, size_t count, FILE *stream)
{
  size_t to_write, bytes, total_bytes = 0;

  PTHREAD_UNSAFE

  /* Check for any errors.  */
  if (!__validfp (stream) || !stream->__mode.__bits.__write)
    {
      (void) __set_errno (EINVAL);
      return (size_t) 0;
    }

  if (ferror (stream))
    return (size_t) 0;

  to_write = size * count;
  if (to_write == 0)
    return (size_t) 0;

#ifdef DEBUG
  debug_printf ("-- fwrite(%d): to_write=%d", stream->fd, to_write);
#endif

  if (stream->o_base != NULL)
    {
  /* The special file descriptor of -1 is used when writing to a
	 memory buffer, such as the function 'sprintf' would.  In this
	 circumstance, if we have been requested to write more data than
	 the buffer contains, truncate it.  */
      if (stream->fd == -1 && to_write > stream->o_cnt)
	{
	  to_write = stream->o_cnt;
	  if (to_write == 0)
	    return (size_t) 0;
	}

      /* Optimisations appropriate for a buffered file.  */
      if (to_write > stream->o_cnt)
	{
#ifdef DEBUG
	  debug_printf (", direct write\n");
#endif
	  /* We have lots of data to output. First flush the buffer,
	     then just write the rest out.  */
	  if (__flsbuf (EOF, stream) < 0)
	    return (size_t) 0; /* we wouldn't have written anything yet.  */

	  /* Write it out in a loop, as recommended.  */
	  while (to_write)
	    {
	      bytes = write (stream->fd, data, to_write);
	      if (bytes == -1)
		{
		  stream->__error = 1;
		  break;
		}
	      to_write -= bytes;
	      /* Increment the internal file offset.  */
	      stream->__offset += bytes;
	      total_bytes += bytes;
	    }
	}
      else
	{
	  /* The data is small enough to place in the output
	     buffer.  */
#ifdef DEBUG
	  debug_printf (", buffering");
#endif
	  bytes = to_write;
	  if (to_write >= 16)
	    {
	      memcpy (stream->o_ptr, data, to_write);
	      to_write -= bytes;
	    }
	  else
	    {
	      /* Try the fast case.  */
	      unsigned char *b = (unsigned char *)data;
	      unsigned char *p = stream->o_ptr;
	      while (to_write-- > 0)
	        *p++ = *b++;
	    }

	  /* Increment the file pointers. */
	  stream->o_ptr += bytes;
	  stream->o_cnt -= bytes;
	  total_bytes += bytes;
	  /* If we're line buffered, look for a newline and
	     flush everything.  */
	  if (stream->__linebuf && stream->o_ptr[-1] == '\n')
	    {
#ifdef DEBUG
	      debug_printf (", flushing\n");
#endif
	      __flsbuf (EOF, stream);
	    }
#ifdef DEBUG
          else
	    debug_printf ("\n");
#endif
	}
    }
  else
    {
#ifdef DEBUG
      debug_printf (", unbuffered write\n");
#endif
      /* Optimisations appropriate for an unbuffered file.
	 We don't have to worry about all that buffer crap :-) */
      while (to_write)
	{
	  /* This check is for (v)snprintf with a NULL buffer */
	  if (stream->fd == -1)
	    bytes = to_write;
	  else
	    bytes = write (stream->fd, data, to_write);

	  if (bytes == -1)
	    {
	      stream->__error = 1;
	      break;
	    }
	  to_write -= bytes;
	  stream->__offset += bytes;
	  total_bytes += bytes;
	}
    }

  /* Return the number of objects actually written.  */
  return total_bytes / size;
}
