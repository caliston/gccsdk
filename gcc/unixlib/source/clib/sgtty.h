/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/clib/sgtty.h,v $
 * $Date: 2001/01/29 15:10:19 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifndef __SGTTY_H
#define __SGTTY_H 1

#ifndef __UNIXLIB_FEATURES_H
#include <unixlib/features.h>
#endif

#include <sys/ioctl.h>

__BEGIN_DECLS

/* Fill in *PARAMS with terminal parameters associated with FD.  */
extern int gtty (int __fd, struct sgttyb * __params);

/* Set the terminal parameters associated with FD to *PARAMS.  */
extern int stty (int __fd, const struct sgttyb *__params);

__END_DECLS

#endif
