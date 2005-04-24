/*
 * AS an assembler for ARM
 * Copyright � 1992 Niklas R�jemo
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 * m_copmem.c
 */

#include "config.h"
#ifdef HAVE_STDINT_H
#include <stdint.h>
#elif HAVE_INTTYPES_H
#include <inttypes.h>
#endif

#include "area.h"
#include "error.h"
#include "expr.h"
#include "get.h"
#include "help_cop.h"
#include "input.h"
#include "mnemonics.h"
#include "option.h"
#include "put.h"
#include "reloc.h"

/** MEMMORY **/


static void
dstmem (WORD ir)
{
  ir |= CP_NUMBER (help_copInt (15, "coprocessor number"));
  skipblanks ();
  if (inputLook () == ',')
    {
      inputSkip ();
      skipblanks ();
    }
  else
    error (ErrorError, TRUE, "%scoprocessor number", InsertCommaAfter);
  ir |= CPDST_OP (getCopReg ());
  ir = help_copAddr (ir, 0);
  putIns (ir);
}

void
m_ldc (WORD cc)
{
  dstmem (cc | 0x0c100000);
}

void
m_stc (WORD cc)
{
  dstmem (cc | 0x0c000000);
}
