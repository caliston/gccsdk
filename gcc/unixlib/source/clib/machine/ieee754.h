/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/gccsdk/unixlib/source/clib/machine/ieee754.h,v $
 * $Date: 2001/01/29 15:10:19 $
 * $Revision: 1.2 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

#ifndef __MACHINE_IEEE754_H
#define __MACHINE_IEEE754_H 1

union ieee754_float
  {
    float f;

    /* This is the IEEE 754 single-precision format.  */
    struct
      {
	unsigned int mantissa:23;
	unsigned int exponent:8;
	unsigned int negative:1;
      } ieee;

    /* This format makes it easier to see if a NaN is a signalling NaN.  */
    struct
      {
	unsigned int mantissa:22;
	unsigned int quiet_nan:1;
	unsigned int exponent:8;
	unsigned int negative:1;
      } ieee_nan;
  };

#define IEEE754_FLOAT_BIAS	0x7f /* Added to exponent.  */


union ieee754_double
  {
    double d;

    /* This is the IEEE 754 double-precision format.  */
    struct
      {
	unsigned int mantissa0:20;
	unsigned int exponent:11;
	unsigned int negative:1;
	unsigned int mantissa1:32;
      } ieee;

    /* This format makes it easier to see if a NaN is a signalling NaN.  */
    struct
      {
	unsigned int mantissa0:19;
	unsigned int quiet_nan:1;
	unsigned int exponent:11;
	unsigned int negative:1;
	unsigned int mantissa1:32;
      } ieee_nan;
  };

#define IEEE754_DOUBLE_BIAS	0x3ff /* Added to exponent.  */


union ieee854_long_double
  {
    long double d;

    /* This is the IEEE 854 double-extended-precision format.  */
    struct
      {
	unsigned int exponent:15;
	unsigned int empty:16;
	unsigned int negative:1;
	unsigned int mantissa0:32;
	unsigned int mantissa1:32;
      } ieee;

    /* This is for NaNs in the IEEE 854 double-extended-precision format.  */
    struct
      {
	unsigned int exponent:15;
	unsigned int empty:16;
	unsigned int negative:1;
	unsigned int mantissa0:30;
	unsigned int quiet_nan:1;
	unsigned int one:1;
	unsigned int mantissa1:32;
      } ieee_nan;
  };

#define IEEE854_LONG_DOUBLE_BIAS 0x3fff


double __ieee754_exp (double x);


#endif
