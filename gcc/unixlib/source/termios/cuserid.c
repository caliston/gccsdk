/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/unixlib/source/termios/c/cuserid,v $
 * $Date: 1998/01/29 21:15:19 $
 * $Revision: 1.1 $
 * $State: Exp $
 * $Author: unixlib $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: cuserid,v 1.1 1998/01/29 21:15:19 unixlib Exp $";
#endif

#include <pwd.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

/* Return the username of the caller.
   If S is not NULL, it points to a buffer of at least L_cuserid bytes
   into which the name is copied; otherwise, a static buffer is used.  */
char *
cuserid (char *s)
{
  static char name[L_cuserid];
  char buf[255 /* NSS_BUFLEN_PASSWD */];
  struct passwd pwent;
  struct passwd *pwptr;

  if (getpwuid_r (geteuid (), &pwent, buf, sizeof (buf), &pwptr))
    {
      if (s != NULL)
	s[0] = '\0';
      return NULL;
    }

  if (s == NULL)
    s = name;
  return strncpy (s, pwptr->pw_name, L_cuserid);
}
