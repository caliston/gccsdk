/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/clib/fcrypt.h,v $
 * $Date: 2001/01/29 15:10:19 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

/* Fcrypt.h: Header file for fcrypt() DES encryption */

#ifndef __FCRYPT_H
#define __FCRYPT_H 1

#ifndef __UNIXLIB_FEATURES_H
#include <unixlib/features.h>
#endif

__BEGIN_DECLS

extern void init_des (void);
extern char *fcrypt (const char *, const char *);

__END_DECLS

#endif
