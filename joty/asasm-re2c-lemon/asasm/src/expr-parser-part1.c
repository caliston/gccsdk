/*
 * AsAsm an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2002-2014 GCCSDK Developers
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

/* This file is included by expr-parser.c and not compiled on its own.  */

#include "config.h"

#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "area.h"
#include "symbol.h"
#include "value.h"

/**
 * Get integer value of a ValueInt and one character ValueString object.
 * Note absolute area symbols are already resolved to integers by
 * having called Value_ResolveSymbol before feeding the evaluation stack.
 * \return true when it concerns a ValueInt or one character ValueString object.
 */
static bool
GetInt (const Value *valP, uint32_t *i)
{
  switch (valP->Tag)
    {
      case ValueInt:
	/* A CPU register list is not a meaningful integer value, so exclude
	   that int type.  */
	if (valP->Data.Int.type != eIntType_CPURList)
	  {
	    *i = (unsigned)valP->Data.Int.i;
	    return true;
	  }
	break;

      case ValueString:
	if (valP->Data.String.len == 1)
	  {
	    *i = (uint8_t)valP->Data.String.s[0];
	    return true;
	  }
	break;

      default:
	break;
    }

  return false;
}

/* No validation checking on value types! */
static int
ememcmp (const Value *lv, const Value *rv)
{
  const size_t lvl = lv->Data.String.len;
  const size_t rvl = rv->Data.String.len;
  int a = memcmp (lv->Data.String.s, rv->Data.String.s, lvl < rvl ? lvl : rvl);
  return a ? a : (int)(lvl - rvl);
}

#define STRINGIFY(OP)	#OP
/* Core implementation for '<', '<=', '>', '>=', '==' and '!='.
   Works for ValueFloat, ValueString, ValueAddr and ValueInt.  */
#define COMPARE(RESULT, LHS, RHS, OP) \
  do \
    { \
      uint32_t lint, rint;\
      if (lvalue->Tag == ValueFloat && rvalue->Tag == ValueFloat) \
	RESULT.value = Value_Bool (lvalue->Data.Float.f OP rvalue->Data.Float.f); \
      else if (lvalue->Tag == ValueString && rvalue->Tag == ValueString) \
	RESULT.value = Value_Bool (ememcmp (lvalue, rvalue) OP 0); \
      else if (GetInt (lvalue, &lint) && GetInt (rvalue, &rint)) \
	RESULT.value = Value_Bool (lint OP rint); /* Comparing integers happens *unsigned* ! */ \
      else if (lvalue->Tag == ValueAddr && rvalue->Tag == ValueAddr) \
	{ \
	  /* ObjAsm implementation: when base register differs, always return false */ \
	  RESULT.value = Value_Bool (lvalue->Data.Addr.r == rvalue->Data.Addr.r && lvalue->Data.Addr.i OP rvalue->Data.Addr.i); \
	} \
      else \
	{ \
	  ExprScanner_Report2 ("Bad operand type for '" STRINGIFY(OP) "'", &LHS.pos, &RHS.pos); \
	  state->err = true; \
	  RESULT.value = Value_Illegal (); \
	} \
    } while (0)


static const char oLowcaseCCodes[] = "eqnecsccmiplvsvchilsgeltgtlealnvhslo";

/**
 * \param str Pointer to condition code (might be NULL but then len should be
 * 0 as well).
 * \param len Length of the condition code.
 * \return The condition code.  Values 16 and 17 are respectively "HS" and
 * "LO" (those correspond to condition codes 2 and 3).
 * Is UINT_MAX when condition code is not known.
 */
static unsigned
GetCCode (const char *str, size_t len)
{
  if (len == 0)
    return 14;
  if (len != 2)
    return UINT_MAX;
  if ((str[0] & 0x20) != (str[1] & 0x20))
    return -1;
  const char lowCase0 = str[0] | 0x20;
  const char lowCase1 = str[1] | 0x20;
  for (size_t result = 0; result != sizeof (oLowcaseCCodes)-1; result += 2)
    {
      if (lowCase0 == oLowcaseCCodes[result + 0] && lowCase1 == oLowcaseCCodes[result + 1])
	return (unsigned)result / 2;
    }
  return UINT_MAX;
}


/**
 * Create new token position being the left of lhs and the right of rhs.
 */
static inline void
UpdateTokenPos(TokenPos_t * restrict result,
	       const TokenPos_t * restrict lhs, const TokenPos_t * restrict rhs)
{
  result->offset = lhs->offset;
  result->size = rhs->offset - lhs->offset + rhs->size;
}


/**
 * Try to convert a ValueAddr or ValueSymbol into ValueAddr (possibly loosing
 * relocation info).
 */
static Value
GetValueAddrEquivalent (const Value *valP)
{
  const RelocAndAddend_t relocAddend = Reloc_SplitRelocAndAddend (valP,
								  areaCurrentSymbol,
								  Area_CurIdxAligned (),
                                                                  false);
  valP = &relocAddend.addend;
  if (valP->Tag == ValueAddr)
    return *valP;
  Value illVal = { .Tag = ValueIllegal };
  return illVal;
}
