/* getgrgid_r ()
 * Search for an entry with a matching group ID (re-entrant version).
 *
 * Copyright (c) 2000-2010 UnixLib Developers
 */

#include <stddef.h>
#include <stdio.h>
#include <errno.h>
#include <grp.h>
#include <sys/types.h>

#include <pthread.h>
#include <internal/unix.h>

int
getgrgid_r (gid_t gid, struct group *resbuf, char *buffer, size_t buflen,
	    struct group **result)
{
  PTHREAD_SAFE_CANCELLATION

  if (resbuf == NULL || buffer == NULL)
    return __set_errno (EINVAL);

  FILE *stream = fopen ("/etc/group", "r");
  if (stream == NULL)
    return -1;

  struct group *grp;
  while ((grp = __grpread (stream, resbuf, buffer, buflen)) != NULL)
    {
      if (resbuf->gr_gid == gid)
        break;
    }

  fclose (stream);

  if (grp == NULL)
    return -1;

  if (result != NULL)
    *result = resbuf;

  return 0;
}
