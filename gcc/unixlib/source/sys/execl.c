/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/sys/execl.c,v $
 * $Date: 2001/01/29 15:10:21 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: execl.c,v 1.2 2001/01/29 15:10:21 admin Exp $";
#endif

#include <stdarg.h>
#include <errno.h>
#include <unistd.h>
#include <sys/param.h>
#include <stdlib.h>

/* Execute path with all arguments after path until a NULL
   pointer and environment from 'environ'.  */

int
execl (const char *path, const char *arg, ...)
{
  char **argv;
  unsigned int i, n;
  va_list args;

  va_start (args, arg);

  n = 8;
  argv = malloc (n * sizeof (const char *));
  if (argv == NULL)
    return __set_errno (E2BIG);
  argv[0] = arg;
  i = 0;
  while (argv[i++] != NULL)
    {
      if (i == n)
        {
          n *= 2;
          argv = realloc (argv, n * sizeof (char *));
          if (argv == NULL)
            return __set_errno (E2BIG);
        }
      argv[i] = va_arg (args, const char *);
    }

  va_end (args);
  i = execve (path, argv, environ);
  free (argv);
  return i;
}
