/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/clib/sys/os.h,v $
 * $Date: 2001/08/02 14:57:14 $
 * $Revision: 1.2.2.1 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifndef __SYS_OS_H
#define __SYS_OS_H

#ifndef __KERNEL_H
#include <kernel.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define os_error _kernel_oserror

/* Setup console I/O.  */
extern int os_console (void);
/* Setup RS423 I/O.  */
extern int os_423 (void);

extern int os_vdu (int);
extern int os_get (void);
/* Returns -1 on timeout.  */
extern int os_inkey (int);
/* Flush keyboard buffer.  */
extern int os_keyflush (void);

/* 423 times are in centiseconds */

extern int os_423vdu (int);
extern int os_423get (void);
/* Returns -1 on timeout.  */
extern int os_423inkey (int);
/* Flush RS423 buffer.  */
extern int os_423flush (void);
extern int os_423break (int);

extern _kernel_oserror *os_swi (int,int * /* 10 reg */ );
extern _kernel_oserror *__os_byte (int,int,int,int * /* 3 reg */ );
extern _kernel_oserror *__os_word (int,void *);
extern _kernel_oserror *os_prhex (int); 	/* %8x format hex output */
extern _kernel_oserror *os_prdec (int);
extern _kernel_oserror *os_print (const char *);
extern _kernel_oserror *os_write (const char *,int);
extern _kernel_oserror *os_nl (void);		/* newline */
extern _kernel_oserror *__os_cli (const char *);
extern _kernel_oserror *os_file (int,const char *,int * /* 6 reg */ );
extern _kernel_oserror *os_fopen (int,const char *,int * /* 1 reg */ );
extern _kernel_oserror *os_fclose (int);
extern _kernel_oserror *os_fread (int,void *,int,int * /* 5 reg */ );
extern _kernel_oserror *os_fwrite (int,const void *,int,int * /* 5 reg */ );
extern _kernel_oserror *os_args (int,int,int,int * /* 3 reg */ );
extern _kernel_oserror *os_fsctrl (int,const char *,char *,int);

#ifdef __UNIXLIB_INTERNALS
/* Flag RISC OS error to UNIX.  */
extern void __seterr (const _kernel_oserror *);
#endif

extern int _swi (int __swi_no, unsigned int, ...);
extern _kernel_oserror *_swix (int __swi_no, unsigned int, ...);

#define _FLAGS     0x10 /*use with _RETURN() or _OUT()*/
#define _IN(i)     (1U << (i))
#define _INR(i,j)  (~0 << (i) ^ ~0 << ((j) + 1))
#define _OUT(i)    ((i) != _FLAGS? (1U << (31 - (i))): 1U << 21)
#define _OUTR(i,j) (~0U >> (i) ^ ~0U >> ((j) + 1))
#define _BLOCK(i)  (1U << 11 | (unsigned) (i) << 12)
#define _RETURN(i) ((i) != _FLAGS? (unsigned) (i) << 16: 0xFU << 16)
#define _C         (1U << 29)
#define _Z         (1U << 30)
#define _N         (1U << 31)


#ifdef __cplusplus
	}
#endif

#endif
