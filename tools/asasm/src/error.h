/*
 * AsAsm an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2002-2013 GCCSDK Developers
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA  02110-1301, USA.
 */

#ifndef error_header_included
#define error_header_included

#include "phase.h"

typedef enum
{
  ErrorInfo,
  ErrorWarning,
  ErrorError, /**< Too many of these are considered as fatal.  */
  ErrorAbort /**< Fatal and last error message.  */
} ErrorTag;

extern const char InsertCommaAfter[];

void Error_PrepareForPhase (Phase_e phase);

void Error_Line (const char *fileName, unsigned lineNum,
		 ErrorTag e, const char *format, ...)
  __attribute__ ((__format__ (__printf__, 4, 5)));
void Error (ErrorTag e, const char *format, ...)
  __attribute__ ((__format__ (__printf__, 2, 3)));

void Error_AbortLine (const char *fileName, unsigned lineNum, const char *format, ...)
  __attribute__ ((noreturn))
  __attribute__ ((__format__ (__printf__, 3, 4)));
void Error_Abort (const char *format, ...)
  __attribute__ ((noreturn))
  __attribute__ ((__format__ (__printf__, 1, 2)));

void Error_OutOfMem (void) __attribute__ ((noreturn));

int Error_GetExitStatus (void);

#endif
