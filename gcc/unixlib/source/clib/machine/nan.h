/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/clib/machine/nan.h,v $
 * $Date: 2001/01/29 15:10:19 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifndef	__MACHINE_NAN_H
#define	__MACHINE_NAN_H	1

/* IEEE Not A Number.  */

extern const char __nan[8];
#define NAN (*(const double *)(const void *) __nan)

#endif
