/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/pwd/getpwnam_r.c,v $
 * $Date: 2000/07/15 14:52:27 $
 * $Revision: 1.1.1.1 $
 * $State: Exp $
 * $Author: nick $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: getpwnam_r.c,v 1.1.1.1 2000/07/15 14:52:27 nick Exp $";
#endif

/* Search for an entry with a matching username (re-entrant version).
   Contributed by Nick Burrett, 10 December 1997.  */

#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <pwd.h>
#include <errno.h>

/* Search for an entry with a matching name.  */
int
getpwnam_r (const char *name, struct passwd *result_buf, char *buffer,
	    size_t buflen, struct passwd **result)
{
  FILE *stream;
  struct passwd *p;

  if (result_buf == NULL)
    return __set_errno (EINVAL);

  stream = fopen ("/etc/passwd", "r");
  if (stream == NULL)
    return -1;

  p = __pwdread (stream, result_buf);
  while (p != NULL)
    {
      if (strcmp (result_buf->pw_name, name) == 0)
        break;
      p = __pwdread (stream, result_buf);
    }

  fclose (stream);

  if (p == NULL)
    return -1;

  if (result != NULL)
    *result = result_buf;

  return 0;
}
