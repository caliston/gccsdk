/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/clib/sched.h,v $
 * $Date: 2005/03/31 12:59:19 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: nick $
 *
 ***************************************************************************/

#ifndef __SCHED_H
#define __SCHED_H

#ifndef __UNIXLIB_FEATURES
#include <features.h>
#endif

__BEGIN_DECLS

#include <bits/sched.h>

extern int sched_yield (void);

__END_DECLS

#endif /* __SCHED_H */

