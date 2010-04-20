/* getservbyport ()
 * Copyright (c) 2010 UnixLib Developers
 */

#include <netdb.h>

#define InetServices_GetServiceByPort 0x55640

struct servent *
getservbyport (int __port, const char *__proto)
{
  register int port __asm ("r0") = __port;
  register int proto __asm ("r1") = __proto;
  struct servent *rtrn;
  __asm volatile ("SWI\t%[SWI_XInetServices_GetServiceByPort]\n\t"
		  "MOVVC\t%[rtrn], r3\n\t"
		  "MOVVS\t%[rtrn], #0\n\t"
		  : [rtrn] "=r" (rtrn)
		  : "r" (port), "r" (proto),
		    [SWI_XInetServices_GetServiceByPort] "i" (InetServices_GetServiceByPort | (1<<17))
		  : "r3", "r14", "cc");
  return rtrn;
}



