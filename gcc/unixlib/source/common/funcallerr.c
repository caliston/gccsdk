/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/common/funcallerr.c,v $
 * $Date: 2001/01/29 15:10:19 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifdef EMBED_RCSID
static const char rcs_id[] = "$Id: funcallerr.c,v 1.2 2001/01/29 15:10:19 admin Exp $";
#endif

#include <signal.h>
#include <sys/unix.h>
#include <sys/os.h>

int
__funcall_error (const char *file, int line, unsigned int addr)
{
  char buf[11];
  char *s = buf + 11;

  os_print ("fatal error: Attempt to call a function at address below 0x");
  os_prhex ((unsigned int) __base);
  os_print ("\n\ror a function at a non word-aligned address in a UnixLib function.\r\nFile: ");
  os_print (file);
  os_print (", line: ");
  do
    {
      *--s = (line % 10) + '0';
      line /= 10;
    }
  while (line != 0);
  os_print (s);
  os_print (", function address: 0x");
  os_prhex (addr);
  os_nl ();

  raise (SIGABRT);
  return 0;
}
