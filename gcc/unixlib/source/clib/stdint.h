/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/clib/stdint.h,v $
 * $Date: 2001/01/29 15:10:19 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifndef __STDINT_H
#define __STDINT_H 1

/* Exact integral types.  */

/* Signed.  */

#ifndef __int8_t_defined
#define __int8_t_defined
typedef signed char int8_t;
typedef short int int16_t;
typedef int int32_t;
typedef long long int int64_t;

/* Unsigned.  */
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long int uint64_t;
#endif


/* Small types.  */

/* Signed.  */
typedef signed char int_least8_t;
typedef short int int_least16_t;
typedef int int_least32_t;
typedef long long int int_least64_t;

/* Unsigned.  */
typedef unsigned char uint_least8_t;
typedef unsigned short int uint_least16_t;
typedef unsigned int uint_least32_t;
typedef unsigned long long int uint_least64_t;


/* Fast types.  */

/* Signed.  */
typedef signed char int_fast8_t;
typedef int int_fast16_t;
typedef int int_fast32_t;
typedef long long int int_fast64_t;

/* Unsigned.  */
typedef unsigned char uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned int uint_fast32_t;
typedef unsigned long long int uint_fast64_t;


/* Types for `void *' pointers.  */
#ifndef __intptr_t_defined
#define __intptr_t_defined
typedef int intptr_t;
typedef unsigned int uintptr_t;
#endif


#ifdef __GNUC__
/* Largest integral types.  */
typedef long long int intmax_t;
typedef unsigned long long int uintmax_t;
#else
/* Largest integral types.  */
typedef long int intmax_t;
typedef unsigned long int uintmax_t;
#endif

/* The ISO C 9X standard specifies that in C++ implementations these
   macros should only be defined if explicitly requested.  */
#if !defined __cplusplus || defined __STDC_LIMIT_MACROS

/* Limits of integral types.  */

/* Minimum of signed integral types.  */
#define INT8_MIN		(-128)
#define INT16_MIN		(-32767-1)
#define INT32_MIN		(-2147483647-1)
#ifdef __GNUC__
#define INT64_MIN		(-9223372036854775807LL-1)
#endif

/* Maximum of signed integral types.  */
#define INT8_MAX		(127)
#define INT16_MAX		(32767)
#define INT32_MAX		(2147483647)
#ifdef __GNUC__
#define INT64_MAX		(9223372036854775807LL)
#endif

/* Maximum of unsigned integral types.  */
#define UINT8_MAX		(255U)
#define UINT16_MAX		(65535U)
#define UINT32_MAX		(4294967295U)
#ifdef __GNUC__
#define UINT64_MAX		(18446744073709551615ULL)
#endif


/* Minimum of signed integral types having a minimum size.  */
#define INT_LEAST8_MIN		(-128)
#define INT_LEAST16_MIN	(-32767-1)
#define INT_LEAST32_MIN	(-2147483647-1)
#ifdef __GNUC__
#define INT_LEAST64_MIN	(-9223372036854775807LL-1)
#endif

/* Maximum of signed integral types having a minimum size.  */
#define INT_LEAST8_MAX		(127)
#define INT_LEAST16_MAX	(32767)
#define INT_LEAST32_MAX	(2147483647)
#ifdef __GNUC__
#define INT_LEAST64_MAX	(9223372036854775807LL)
#endif

/* Maximum of unsigned integral types having a minimum size.  */
#define UINT_LEAST8_MAX	(255U)
#define UINT_LEAST16_MAX	(65535U)
#define UINT_LEAST32_MAX	(4294967295U)
#ifdef __GNUC__
#define UINT_LEAST64_MAX	(18446744073709551615ULL)
#endif

/* Minimum of fast signed integral types having a minimum size.  */
#define INT_FAST8_MIN		(-128)
#define INT_FAST16_MIN		(-2147483647-1)
#define INT_FAST32_MIN		(-2147483647-1)
#ifdef __GNUC__
#define INT_FAST64_MIN		(-9223372036854775807LL-1)

/* Maximum of fast signed integral types having a minimum size.  */
#define INT_FAST8_MAX		(127)
#define INT_FAST16_MAX		(2147483647)
#define INT_FAST32_MAX		(2147483647)
#ifdef __GNUC__
#define INT_FAST64_MAX		(9223372036854775807LL)
#endif

/* Maximum of fast unsigned integral types having a minimum size.  */
#define UINT_FAST8_MAX		(255U)
#define UINT_FAST16_MAX	(4294967295U)
#define UINT_FAST32_MAX	(4294967295U)
#ifdef __GNUC__
#define UINT_FAST64_MAX	(18446744073709551615ULL)
#endif


/* Values to test for integral types holding `void *' pointer.  */
#define INTPTR_MIN		(-2147483647-1)
#define INTPTR_MAX		(2147483647)
#define UINTPTR_MAX		(4294967295U)


#ifdef __GNUC__
/* Minimum for largest signed integral type.  */
#define INTMAX_MIN		(-9223372036854775807LL-1)
/* Maximum for largest signed integral type.  */
#define INTMAX_MAX		(9223372036854775807LL)

/* Maximum for largest unsigned integral type.  */
#define UINTMAX_MAX		(18446744073709551615ULL)
#endif

/* Limits of other integer types.  */

/* Limits of `ptrdiff_t' type.  */
#define PTRDIFF_MIN	(-2147483647-1)
#define PTRDIFF_MAX	(2147483647)

/* Limits of `sig_atomic_t'.  */
#define SIG_ATOMIC_MIN	(-2147483647-1)
#define SIG_ATOMIC_MAX	(2147483647)

/* Limit of `size_t' type.  */
#define SIZE_MAX	(4294967295U)

/* Limits of `wchar_t'.  */
#ifndef WCHAR_MIN
/* These constants might also be defined in <wchar.h>.  */
#define WCHAR_MIN	(-2147483647-1)
#define WCHAR_MAX	(2147483647)
#endif

/* Limits of `wint_t'.  */
#define WINT_MIN	(0)
#define WINT_MAX	(4294967295U)

#endif	/* C++ && limit macros */

#if !defined __cplusplus || defined __STDC_CONSTANT_MACROS

/* Signed.  */
#define INT8_C(c)	c
#define INT16_C(c)	c
#define INT32_C(c)	c
#define INT64_C(c)	c ## LL

/* Unsigned.  */
#define UINT8_C(c)	c ## U
#define UINT16_C(c)	c ## U
#define UINT32_C(c)	c ## U
#define UINT64_C(c)	c ## ULL

/* Maximal type.  */
#define INTMAX_C(c)	c ## LL
#define UINTMAX_C(c)	c ## ULL

#endif

#endif
