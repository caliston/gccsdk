/****************************************************************************
 *
 * $Source: $
 * $Date: $
 * $Revision: $
 * $State: $
 * $Author: $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: $";
#endif

/* Read a group password file entry. */

#include <stddef.h>
#include <stdio.h>
#include <grp.h>

/* Read one entry from the given stream.  */
struct group *
fgetgrent (FILE * stream)
{
  static struct group grp;

  if (stream == NULL)
    return NULL;

  return __grpread (stream, &grp);
}
