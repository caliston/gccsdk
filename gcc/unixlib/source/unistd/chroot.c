/**************************************************************************** 
 * 
 * $Source$
 * $Date$
 * $Revision$
 * $State$
 * $Author$
 * 
 ***************************************************************************/ 
 
#include <errno.h> 
#include <unistd.h> 
 
int 
chroot (const char *path) 
{ 
  path = path; 
 
  return __set_errno (ENOSYS); 
} 
