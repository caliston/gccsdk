/* strspn ()
 * Copyright (c) 2000-2006 UnixLib Developers
 */

#include <string.h>

size_t
strspn (const char *s1, const char *s)
{
  int c1, c2;
  const char *s2;
  size_t n = 0;

  while ((c1 = *s1++))
    {
      s2 = s;
      while ((c2 = *s2++) != c1)
	if (!c2)
	  return n;
      n++;
    }

  return n;
}
