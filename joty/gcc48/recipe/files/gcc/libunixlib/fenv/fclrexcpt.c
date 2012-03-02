/*
 * File taken from glibc.
 *  - SCL poison added.
 */
#ifdef __TARGET_SCL__
#  error "SCL build should not use (L)GPL code."
#endif

/* Clear given exceptions in current floating-point environment.
   Copyright (C) 1997,98,99,2000,01 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#include <fenv.h>
#include <fpu_control.h>

int feclearexcept (int excepts)
{
#ifndef __SOFTFP__
  unsigned long int temp;

  /* Mask out unsupported bits/exceptions.  */
  excepts &= FE_ALL_EXCEPT;

  /* Get the current floating point status. */
  _FPU_GETCW (temp);

  /* Clear the relevant bits.  */
  temp &= excepts ^ FE_ALL_EXCEPT;

  /* Put the new data in effect.  */
  _FPU_SETCW (temp);

 /* Success.  */
#endif
  return 0;
}
