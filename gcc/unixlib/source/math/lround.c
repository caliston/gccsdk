/****************************************************************************
 *
 * $Source: /usr/local/cvsroot/unixlib/source/math/c/lround,v $
 * $Date: 1999/11/16 13:31:17 $
 * $Revision: 1.1 $
 * $State: Exp $
 * $Author: admin $
 *
 ***************************************************************************/

/* Round double value to long int.
   Copyright (C) 1997 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper <drepper@cygnus.com>, 1997.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

#include <math.h>
#include <unixlib/math.h>
#include <unixlib/types.h>

long int
lround (double x)
{
  __int32_t j0;
  __u_int32_t i1, i0;
  long int result;
  int sign;

  EXTRACT_WORDS (i0, i1, x);
  j0 = ((i0 >> 20) & 0x7ff) - 0x3ff;
  sign = (i0 & 0x80000000) != 0 ? -1 : 1;
  i0 &= 0xfffff;
  i0 |= 0x100000;

  if (j0 < 20)
    {
      if (j0 < 0)
	return j0 < -1 ? 0 : sign;
      else
	{
	  i0 += 0x80000 >> j0;

	  result = i0 >> (20 - j0);
	}
    }
  else if (j0 < (__int32_t) (8 * sizeof (long int)) - 1)
    {
      if (j0 >= 52)
	result = ((long int) i0 << (j0 - 20)) | (i1 << (j0 - 52));
      else
	{
	  __u_int32_t j = i1 + (0x80000000 >> (j0 - 20));
	  if (j < i1)
	    ++i0;

	  result = ((long int) i0 << (j0 - 20)) | (j >> (52 - j0));
	}
    }
  else
    {
      /* The number is too large.  It is left implementation defined
	 what happens.  */
      return (long int) x;
    }

  return sign * result;
}
