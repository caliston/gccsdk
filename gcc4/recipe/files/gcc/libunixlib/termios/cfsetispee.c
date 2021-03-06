/* cfsetispeed ()
 * Copyright (c) 2000-2006 UnixLib Developers
 */

#include <errno.h>
#include <stdlib.h>
#include <termios.h>

/* Set input baud rate stored in the termios structure.
   Implementation defined as to whether to return an error if baud rate is
   not possible (e.g. hardware can't support speed, or can't support split
   rates.
   NetBSD makes no effort to return errors, so we won't.  */
int
cfsetispeed (struct termios *termios_p, __speed_t speed)
{
  if (termios_p == NULL || speed > __MAX_BAUD)
    return __set_errno (EINVAL);

  termios_p->c_ispeed = speed;
  return 0;
}
