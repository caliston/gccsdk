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

/* lemon will create expr-parser-part2.c from expr-parser-part2.y and the
   former will be included by expr-parser.c and not compiled on its own.  */

%include
{
#include "config.h"

#include <assert.h>
#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "error.h"
#include "expr-scanner.h"
#include "filestack.h"
#include "include.h"
#include "os.h"
#include "value.h"

typedef struct
{
  Value value;
  TokenPos_t pos;
} ExprType_t;

/* Upfront declare a useful parser routine.  */
struct yyParser;
static void yy_parse_failed (struct yyParser *yypParser);
}

%token_prefix TOKEN_
%extra_argument { ParserState_t *state }

%token_type { ParseTerminal_t } /* For terminals.  */
%default_type { ExprType_t } /* For non-terminals.  */
//%default_destructor /* For destructing all other terminals.  */
//{
//printf ("Destr: default: major %d, value tag %d\n", yymajor, $$.value.Tag);
//  Value_Free(&$$.value);
//}
/* Instead of providing a general destructor, give one specific for 'expr'
   which will be called when 'expr' stack elements get unwinded (in case of
   an error or forced parser destruction.  Or when 'expr' are used in rules
   without a parameter.  */
%destructor expr
{
printf ("Destr: expr: major %d, value tag %d\n", yymajor, $$.value.Tag);
  Value_Free(&$$.value);
}
/* Don't provide a non-terminal destructor unless it is really needed.
   FIXME: check non-owning ValueString case.  */
//%token_destructor /* For destructing non-terminals.  */
//{
//printf ("Destr: token: major %d, value tag %d\n", yymajor, $$.value.Tag);
//  Value_Free(&$$.value);
//}

%parse_accept
{
  fprintf (stderr, "xxx parse_accept\n");
}

%parse_failure
{
  fprintf (stderr, "xxx parse_failure called\n");
  state->err = true;
}

%syntax_error
{
  if (state->err)
    {
      printf ("FIXME: surpressing syntax error because of previous error\n");
    }
  else
    {
      fprintf (stderr, "xxx syntax error when processing token %d\n", yymajor);
      ExprScanner_Report1 ("Syntax error", &TOKEN.pos);
      printf ("Value token is: ");
#ifdef DEBUG
      Value_Print(&TOKEN.value); printf ("\n");
#endif
      state->err =  true;
    }
}

/* Terminal symbols, order from low to high precedence.  */
%left OP_LAND OP_LOR OP_LEOR. /* Binary boolean operations.  */
%left OP_LE OP_GE OP_LT OP_GT OP_EQ OP_NE. /* Binary relational operations.  */
%left OP_ADD OP_SUB OP_AND OP_OR OP_EOR. /* Binary add/and/logical operations.  */
%left OP_ASR OP_SHR OP_SHL OP_ROR OP_ROL. /* Binary shift operations.  */
%left OP_LEFT OP_RIGHT OP_CONCAT. /* Binary string operations.  */
%left OP_MUL OP_DIV OP_MOD. /* Binary multiplicative operations.  */
%left OP_FLOAD OP_FEXEC OP_FSIZE OP_FATTR OP_LNOT OP_NOT
  OP_BASE OP_INDEX OP_LEN OP_STR OP_CHR
  OP_SIZE OP_LOWERCASE OP_UPPERCASE OP_REVCC OP_CCENC
  OP_RCONST OP_DEF. /* Unary operations.  */
%left OP_RB_OPEN OP_RB_CLOSE. /* Round brackets.  */

program ::= expr(A).
  {
    *state->resultP = A.value;
  }

/* Binary boolean operations.  */
expr(RESULT) ::= expr(LHS) OP_LAND expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    if (lvalue->Tag == ValueBool && rvalue->Tag == ValueBool)
      RESULT.value = Value_Bool (lvalue->Data.Bool.b && rvalue->Data.Bool.b);
    else
      {
	if (lvalue->Tag == ValueBool && rvalue->Tag != ValueBool)
	  ExprScanner_Report1 ("Bad operand type for 'logical AND'", &RHS.pos);
	else if (lvalue->Tag != ValueBool && rvalue->Tag == ValueBool)
	  ExprScanner_Report1 ("Bad operand type for 'logical AND'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'logical AND'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_LOR expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    if (lvalue->Tag == ValueBool && rvalue->Tag == ValueBool)
      RESULT.value = Value_Bool (lvalue->Data.Bool.b || rvalue->Data.Bool.b);
    else
      {
	if (lvalue->Tag == ValueBool && rvalue->Tag != ValueBool)
	  ExprScanner_Report1 ("Bad operand type for 'logical OR'", &RHS.pos);
	else if (lvalue->Tag != ValueBool && rvalue->Tag == ValueBool)
	  ExprScanner_Report1 ("Bad operand type for 'logical OR'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'logical OR'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_LEOR expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    if (lvalue->Tag == ValueBool && rvalue->Tag == ValueBool)
      RESULT.value = Value_Bool (lvalue->Data.Bool.b ^ rvalue->Data.Bool.b);
    else
      {
	if (lvalue->Tag == ValueBool && rvalue->Tag != ValueBool)
	  ExprScanner_Report1 ("Bad operand type for 'logical EOR'", &RHS.pos);
	else if (lvalue->Tag != ValueBool && rvalue->Tag == ValueBool)
	  ExprScanner_Report1 ("Bad operand type for 'logical EOR'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'logical EOR'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

/* Binary relational operations.  */
expr(RESULT) ::= expr(LHS) OP_LE expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    COMPARE (RESULT, LHS, RHS, <=);
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_GE expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    COMPARE (RESULT, LHS, RHS, >=);
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_LT expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    COMPARE (RESULT, LHS, RHS, <);
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_GT expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    COMPARE (RESULT, LHS, RHS, >);
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_EQ expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    if ((lvalue->Tag & (ValueBool | ValueSymbol | ValueCode)) != 0 // FIXME: Remove support for ValueCode ?
	&& (rvalue->Tag & (ValueBool | ValueSymbol | ValueCode)) != 0)
      RESULT.value = Value_Bool (Value_Equal (lvalue, rvalue));
    else
      COMPARE (RESULT, LHS, RHS, ==);
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_NE expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    if ((lvalue->Tag & (ValueBool | ValueSymbol | ValueCode)) != 0 // FIXME: Remove support for ValueCode ?
	&& (rvalue->Tag & (ValueBool | ValueSymbol | ValueCode)) != 0)
      RESULT.value = Value_Bool (!Value_Equal (lvalue, rvalue));
    else
      COMPARE (RESULT, LHS, RHS, !=);
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

/* Binary add/and/logical operations.  */
expr(RESULT) ::= expr(LHS) OP_ADD expr(RHS).
  {
    /* Promotion for ValueFloat, ValueAddr and ValueSymbol.  */
    bool doPromotion = RHS.value.Tag == ValueFloat || RHS.value.Tag == ValueAddr
			 || RHS.value.Tag == ValueSymbol;
    const Value * restrict lvalue = doPromotion ? &RHS.value : &LHS.value;
    const Value * restrict rvalue = doPromotion ? &LHS.value : &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);

    if (lvalue->Tag == ValueAddr && r_isint) /* ValueAddr <= ValueAddr + ValueInt  <or>  ValueInt + ValueAddr */
      RESULT.value = Value_Addr (lvalue->Data.Addr.r, lvalue->Data.Addr.i + rval);
    else if (lvalue->Tag == ValueSymbol && rvalue->Tag == ValueSymbol
	     && lvalue->Data.Symbol.symbol == rvalue->Data.Symbol.symbol) /* ValueSymbol <or> ValueInt <= ValueSymbol + ValueSymbol */
      {
	  int factor = lvalue->Data.Symbol.factor + rvalue->Data.Symbol.factor;
	  int offset = lvalue->Data.Symbol.offset + rvalue->Data.Symbol.offset;
	  RESULT.value = factor == 0 ? Value_Int (offset, eIntType_PureInt) : Value_Symbol (lvalue->Data.Symbol.symbol, factor, offset);
      }
    else if (lvalue->Tag == ValueSymbol && r_isint)
      RESULT.value = Value_Symbol (lvalue->Data.Symbol.symbol, lvalue->Data.Symbol.factor, lvalue->Data.Symbol.offset + rval);
    else if (l_isint && r_isint) /* ValueInt <= ValueInt + ValueInt */
      RESULT.value = Value_Int (lval + rval, eIntType_PureInt);
    else if (lvalue->Tag == ValueFloat
	     && (r_isint || rvalue->Tag == ValueFloat)) /* ValueFloat <= ValueFloat + ValueInt  <or>  ValueInt + ValueFloat */
      RESULT.value = Value_Float (lvalue->Data.Float.f + (r_isint ? (signed)rval : rvalue->Data.Float.f)); 
    else
      {
	ExprScanner_Report2 ("Bad operand type for 'addition'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_SUB expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);

    if (lvalue->Tag == ValueFloat && rvalue->Tag == ValueFloat) /* ValueFloat <= ValueFloat - ValueFloat */
      RESULT.value = Value_Float (lvalue->Data.Float.f - rvalue->Data.Float.f);
    else if (lvalue->Tag == ValueFloat && r_isint)
      RESULT.value = Value_Float (lvalue->Data.Float.f - (signed)rval); /* ValueFloat <= ValueFloat - ValueInt */
    else if (l_isint && rvalue->Tag == ValueFloat) /* ValueFloat <= ValueInt - ValueFloat */
      RESULT.value = Value_Float ((signed)lval - rvalue->Data.Float.f);
    else if (l_isint && r_isint) /* ValueInt <= ValueInt - ValueInt */
      RESULT.value = Value_Int (lval - rval, eIntType_PureInt);
    else if (lvalue->Tag == ValueAddr && rvalue->Tag == ValueAddr) /* ValueInt <= ValueAddr - ValueAddr */
      {
	if (lvalue->Data.Addr.r != rvalue->Data.Addr.r)
	  {
	    ExprScanner_Report2 ("Base registers are different in subtraction", &LHS.pos, &RHS.pos);
	    // FIXME  Error (ErrorError, "Base registers are different in subtraction ([r%d, #x] - [r%d, #y])",
	    //     lvalue->Data.Addr.r, rvalue->Data.Addr.r);
	    yy_parse_failed (yypParser);
	  }
	else
	  RESULT.value = Value_Int (lvalue->Data.Addr.i - rvalue->Data.Addr.i, eIntType_PureInt);
      }
    else if (lvalue->Tag == ValueAddr && r_isint) /* ValueAddr <= ValueAddr - ValueInt */
      RESULT.value = Value_Addr (lvalue->Data.Addr.r, lvalue->Data.Addr.i - (signed)rval);
    else if ((lvalue->Tag == ValueSymbol || l_isint)
	     && (rvalue->Tag == ValueSymbol || r_isint)
	     && (lvalue->Tag != ValueSymbol || rvalue->Tag != ValueSymbol
		 || lvalue->Data.Symbol.symbol == rvalue->Data.Symbol.symbol))
      {
	assert (!(l_isint && r_isint) && "Needs to be handled elsewhere");
	Symbol *symbol = (lvalue->Tag == ValueSymbol) ? lvalue->Data.Symbol.symbol : rvalue->Data.Symbol.symbol;
	int factor = (lvalue->Tag == ValueSymbol) ? lvalue->Data.Symbol.factor : 0;
	if (rvalue->Tag == ValueSymbol)
	  factor -= rvalue->Data.Symbol.factor;
	int offset = (lvalue->Tag == ValueSymbol) ? lvalue->Data.Symbol.offset : (signed)lval;
	offset -= (rvalue->Tag == ValueSymbol) ? rvalue->Data.Symbol.offset : (signed)rval;
	RESULT.value = factor ? Value_Symbol (symbol, factor, offset) : Value_Int (offset, eIntType_PureInt);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for 'subtraction'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_AND expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      RESULT.value = Value_Int (lval & rval, eIntType_PureInt);
    else
      {
	if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'bitwise AND'", &RHS.pos);
	else if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'bitwise AND'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'bitwise AND'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_OR expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      RESULT.value = Value_Int (lval | rval, eIntType_PureInt);
    else
      {
	if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'bitwise OR'", &RHS.pos);
	else if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'bitwise OR'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'bitwise OR'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_EOR expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      RESULT.value = Value_Int (lval ^ rval, eIntType_PureInt);
    else
      {
	if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'bitwise EOR'", &RHS.pos);
	else if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'bitwise EOR'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'bitwise EOR'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

/* Binary shift operations.  */
expr(RESULT) ::= expr(LHS) OP_ASR expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      {
	unsigned numbits = rval >= 32 ? 1 : 32 - rval;
	unsigned mask = 1U << (numbits - 1);
	uint32_t nosign = lval >> (32 - numbits);
	RESULT.value = Value_Int ((nosign ^ mask) - mask, eIntType_PureInt);
      }
    else
      {
	if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'ASR'", &RHS.pos);
	else if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'ASR'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'ASR'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_SHR expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      RESULT.value = Value_Int (rval >= 32 ? 0 : lval >> rval, eIntType_PureInt);
    else
      {
	if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'SHR'", &LHS.pos);
	else if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'SHR'", &RHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'SHR'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_SHL expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      RESULT.value = Value_Int (rval >= 32 ? 0 : lval << rval, eIntType_PureInt);
    else
      {
	if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'SHL'", &LHS.pos);
	else if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'SHL'", &RHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'SHL'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_ROR expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      {
	unsigned numbits = rval & 31;
	RESULT.value = Value_Int ((lval >> numbits) | (lval << (32 - numbits)), eIntType_PureInt);
      }
    else
      {
	if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'ROR'", &LHS.pos);
	else if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'ROR'", &RHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'ROR'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_ROL expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (l_isint && r_isint)
      {
	unsigned numbits = rval & 31;
	RESULT.value = Value_Int ((lval << numbits) | (lval >> (32 - numbits)), eIntType_PureInt);
      }
    else
      {
	if (!l_isint && r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'ROL'", &LHS.pos);
	else if (l_isint && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for 'ROL'", &RHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'ROL'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

/* Binary string operations.  */
expr(RESULT) ::= expr(LHS) OP_LEFT expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t rval;
    bool r_isint = GetInt (rvalue, &rval);
    if (lvalue->Tag == ValueString && r_isint)
      {
	if (rval <= lvalue->Data.String.len)
	  {
	    char *strP;
	    if ((strP = malloc (rval)) == NULL)
	      Error_OutOfMem ();
	    memcpy (strP, lvalue->Data.String.s, rval);
	    RESULT.value = Value_String (strP, rval, true); // FIXME: when owning string, we could reuse existing malloc block.
	  }
	else
	  {
	    ExprScanner_Report1 ("Wrong number of characters specified for :LEFT:", &RHS.pos);
	    yy_parse_failed (yypParser);
	  }
      }
    else
      {
	if (lvalue->Tag != ValueString && r_isint)
	  ExprScanner_Report1 ("Bad operand type for ':LEFT:'", &LHS.pos);
	else if (lvalue->Tag == ValueString && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for ':LEFT:'", &RHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for ':LEFT:'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_RIGHT expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t rval;
    bool r_isint = GetInt (rvalue, &rval);
    if (lvalue->Tag == ValueString && r_isint)
      {
	if (rval <= lvalue->Data.String.len)
	  {
	    char *strP;
	    if ((strP = malloc (rval)) == NULL)
	      Error_OutOfMem ();
	    memcpy (strP,
		    lvalue->Data.String.s + lvalue->Data.String.len - rval,
		    rval);
	    RESULT.value = Value_String (strP, rval, true); // FIXME: when owning string, we could reuse existing malloc block.
	  }
	else
	  {
	    ExprScanner_Report1 ("Wrong number of characters specified for :RIGHT:", &RHS.pos);
	    yy_parse_failed (yypParser);
	  }
      }
    else
      {
	if (lvalue->Tag != ValueString && r_isint)
	  ExprScanner_Report1 ("Bad operand type for ':RIGHT:'", &LHS.pos);
	else if (lvalue->Tag == ValueString && !r_isint)
	  ExprScanner_Report1 ("Bad operand type for ':RIGHT:'", &RHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for ':RIGHT:'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_CONCAT expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    if (lvalue->Tag == ValueString && rvalue->Tag == ValueString)
      {
	size_t len = lvalue->Data.String.len + rvalue->Data.String.len;
	char *c;
	if ((c = malloc (len)) == NULL)
	  Error_OutOfMem ();
	memcpy (c, lvalue->Data.String.s, lvalue->Data.String.len);
	memcpy (c + lvalue->Data.String.len,
	        rvalue->Data.String.s, rvalue->Data.String.len);
	RESULT.value = Value_String (c, len, true);
      }
    else
      {
	if (lvalue->Tag == ValueString && rvalue->Tag != ValueString)
	  ExprScanner_Report1 ("Bad operand type for 'string concatenation'", &RHS.pos);
	else if (lvalue->Tag != ValueString && rvalue->Tag == ValueString)
	  ExprScanner_Report1 ("Bad operand type for 'string concatenation'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for 'string concatenation'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }

    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

/* Binary multiplicative operations.  */
expr(RESULT) ::= expr(LHS) OP_MUL expr(RHS).
  {
    /* Promotion for ValueFloat and ValueSymbol.  */
    bool doPromotion = RHS.value.Tag == ValueFloat || RHS.value.Tag == ValueSymbol;
    const Value * restrict lvalue = doPromotion ? &RHS.value : &LHS.value;
    const Value * restrict rvalue = doPromotion ? &LHS.value : &RHS.value;

    uint32_t lval, rval;
    bool l_isint = GetInt (lvalue, &lval);
    bool r_isint = GetInt (rvalue, &rval);
    if (lvalue->Tag == ValueSymbol && r_isint) /* ValueSymbol <= ValueSymbol * ValueInt  <or>  ValueInt * ValueSymbol */
      RESULT.value = Value_Symbol (lvalue->Data.Symbol.symbol, lvalue->Data.Symbol.factor * (signed)rval, lvalue->Data.Symbol.offset * (signed)rval);
    else if (lvalue->Tag == ValueFloat && (r_isint || rvalue->Tag == ValueFloat)) /* ValueFloat <= ValueFloat * ValueInt  <or>  ValueInt * ValueFloat */
      RESULT.value = Value_Float (lvalue->Data.Float.f * (r_isint ? (signed)rval : rvalue->Data.Float.f));
    else if (l_isint && r_isint)
      RESULT.value = Value_Int (lval * rval, eIntType_PureInt);
    else
      {
	ExprScanner_Report2 ("Bad operand type for '*'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_DIV expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t divident, divisor; /* Pure integer division is *unsigned*.  */
    bool divident_isint = GetInt (lvalue, &divident);
    bool divisor_isint = GetInt (rvalue, &divisor);
    if ((divident_isint || lvalue->Tag == ValueFloat)
	&& (divisor_isint || rvalue->Tag == ValueFloat))
      {
	double divisor_dbl = divisor_isint ? (double)(signed)divisor : rvalue->Data.Float.f;
	if (divisor_dbl == 0.)
	  {
	    ExprScanner_Report2 ("Division by zero", &LHS.pos, &RHS.pos);
	    yy_parse_failed (yypParser);
	  }
	else if (divident_isint && divisor_isint)
	  RESULT.value = Value_Int (divident / divisor, eIntType_PureInt);
	else
	  {
	    /* Floating point division (signed).  */
	    double divident_dbl = divident_isint ? (double)(signed)divident : lvalue->Data.Float.f;
	    RESULT.value = Value_Float (divident_dbl / divisor_dbl);
	  }
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for '/'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

expr(RESULT) ::= expr(LHS) OP_MOD expr(RHS).
  {
    const Value * restrict lvalue = &LHS.value;
    const Value * restrict rvalue = &RHS.value;

    uint32_t divident, modulus; /* Modulo is *unsigned*.  */
    bool divident_isint = GetInt (lvalue, &divident);
    bool modulus_isint = GetInt (rvalue, &modulus);
    if (divident_isint && modulus_isint)
      {
	if (modulus == 0)
	  {
	    ExprScanner_Report2 ("Division by zero", &LHS.pos, &RHS.pos);
	    yy_parse_failed (yypParser);
	  }
	else
	  RESULT.value = Value_Int (divident % modulus, eIntType_PureInt);
      }
    else
      {
	if (divident_isint && !modulus_isint)
	  ExprScanner_Report1 ("Bad operand type for '%'", &RHS.pos);
	else if (!divident_isint && modulus_isint)
	  ExprScanner_Report1 ("Bad operand type for '%'", &LHS.pos);
	else
	  ExprScanner_Report2 ("Bad operand type for '%'", &LHS.pos, &RHS.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &LHS.pos, &RHS.pos);
  }

/* Unary operations.  */
expr(RESULT) ::= OP_FLOAD(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	char *s;
	if ((s = strndup (value->Data.String.s, value->Data.String.len)) == NULL)
	  Error_OutOfMem ();

	ASFile asFile;
	if (!Include_Find (s, &asFile))
	  {
	    /* Register canonicalised filename so that it gets output
	       in the depends file.  */
	    (void) FS_StoreFileName (asFile.canonName);
	    RESULT.value = Value_Int (asFile.loadAddress, eIntType_PureInt);
	  }
	else
	  {
	    // FIXME: Error (ErrorError, "Cannot access file \"%s\"", s);
	    ExprScanner_Report1 ("Cannot access file", &SRC.pos);
	    yy_parse_failed (yypParser);
	  }
	ASFile_Free (&asFile);
	free (s);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':FLOAD:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_FEXEC(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	char *s;
	if ((s = strndup (value->Data.String.s, value->Data.String.len)) == NULL)
	  Error_OutOfMem ();

	ASFile asFile;
	if (!Include_Find (s, &asFile))
	  {
	    /* Register canonicalised filename so that it gets output
	       in the depends file.  */
	    (void) FS_StoreFileName (asFile.canonName);
	    RESULT.value = Value_Int (asFile.execAddress, eIntType_PureInt);
	  }
	else
	  {
	    // FIXME: Error (ErrorError, "Cannot access file \"%s\"", s);
	    ExprScanner_Report1 ("Cannot access file", &SRC.pos);
	    yy_parse_failed (yypParser);
	  }
	ASFile_Free (&asFile);
	free (s);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':FEXEC:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_FSIZE(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	char *s;
	if ((s = strndup (value->Data.String.s, value->Data.String.len)) == NULL)
	  Error_OutOfMem ();

	ASFile asFile;
	if (!Include_Find (s, &asFile))
	  {
	    /* Register canonicalised filename so that it gets output
	       in the depends file.  */
	    (void) FS_StoreFileName (asFile.canonName);
	    uint32_t fsize;
	    if (asFile.size > UINT32_MAX)
	      {
		Error (ErrorWarning, "File size of \"%s\" is bigger than unsigned 32-bit integer", s);
		fsize = UINT32_MAX;
	      }
	    else
	      fsize = asFile.size;
	    RESULT.value = Value_Int (fsize, eIntType_PureInt);
	  }
	else
	  {
	    // FIXME: Error (ErrorError, "Cannot access file \"%s\"", s);
	    ExprScanner_Report1 ("Cannot access file", &SRC.pos);
	    yy_parse_failed (yypParser);
	  }
	ASFile_Free (&asFile);
	free (s);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':FSIZE:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_FATTR(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	char *s;
	if ((s = strndup (value->Data.String.s, value->Data.String.len)) == NULL)
	  Error_OutOfMem ();

	ASFile asFile;
	if (!Include_Find (s, &asFile))
	  {
	    /* Register canonicalised filename so that it gets output
	       in the depends file.  */
	    (void) FS_StoreFileName (asFile.canonName);
	    RESULT.value = Value_Int (asFile.attribs, eIntType_PureInt);
	  }
	else
	  {
	    // FIXME: Error (ErrorError, "Cannot access file \"%s\"", s);
	    ExprScanner_Report1 ("Cannot access file", &SRC.pos);
	    yy_parse_failed (yypParser);
	  }
	ASFile_Free (&asFile);
	free (s);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':FATTR:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_LNOT(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueBool)
      {
	RESULT.value = Value_Bool (!value->Data.Bool.b);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':LNOT:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_NOT(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    uint32_t i;
    if (GetInt (value, &i))
      {
	RESULT.value = Value_Int (~i, eIntType_PureInt);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':NOT:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_BASE(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    Value addrVal = GetValueAddrEquivalent (value);
    if (addrVal.Tag == ValueAddr)
      {
        RESULT.value = Value_Int (addrVal.Data.Addr.r, eIntType_PureInt);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':BASE:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_INDEX(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    uint32_t i;
    if (GetInt (value, &i))
      RESULT.value = Value_Int (i, eIntType_PureInt);
    else
      {
	Value addrVal = GetValueAddrEquivalent (value);
	if (addrVal.Tag == ValueAddr)
	  {
	    RESULT.value = Value_Int (addrVal.Data.Addr.i, eIntType_PureInt);
	  }
	else
	  {
	    ExprScanner_Report2 ("Bad operand type for ':INDEX:'", &OP.pos, &SRC.pos);
	    yy_parse_failed (yypParser);
	  }
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_LEN(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	RESULT.value = Value_Int (value->Data.String.len, eIntType_PureInt);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':LEN:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_STR(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    switch (value->Tag)
      {
	case ValueBool:
	case ValueInt:
	case ValueFloat:
	  {
	    size_t len;
	    char num[32];
	    switch (value->Tag)
	      {
		case ValueBool:
		  len = sprintf (num, "%c", value->Data.Bool.b ? 'T' : 'F');
		  break;
		case ValueInt:
		  len = sprintf (num, "%.8X", value->Data.Int.i);
		  break;
		case ValueFloat:
		  len = sprintf (num, "%f", value->Data.Float.f);
		  break;
	      }
	    char *c;
	    if ((c = malloc (len)) == NULL)
	      Error_OutOfMem();
	    memcpy (c, num, len);
	    RESULT.value = Value_String (c, len, true);
	    break;
	  }

	default:
	  {
	    ExprScanner_Report2 ("Bad operand type for ':STR:'", &OP.pos, &SRC.pos);
	    yy_parse_failed (yypParser);
	    break;
	  }
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_CHR(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    uint32_t i;
    if (GetInt (value, &i))
      {
	if (i >= 256)
	  { } // FIXME: Error (ErrorWarning, "Value %d will be truncated for :CHR: use", i);
	char *c;
	if ((c = malloc (1)) == NULL)
	  Error_OutOfMem ();
	*c = i;
	RESULT.value = Value_String (c, 1, true);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':CHR:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_SIZE(OP) expr_symbol(SRC).
  {
    const Value *value = &SRC.value;

    assert (value->Tag == ValueSymbol);
    if ((value->Data.Symbol.symbol->attr.type & (SYMBOL_DEFINED | SYMBOL_COMMON)) != 0)
      RESULT.value = Value_Int (value->Data.Symbol.symbol->attr.codeSize, eIntType_PureInt);
    else if (value->Data.Symbol.symbol->attr.type & SYMBOL_AREA)
      {
	//if (gPhase == ePassTwo
	//    && value->Data.Symbol.symbol->attr.area->curIdx != value->Data.Symbol.symbol->attr.area->maxIdx)
	//  {} // FIXME: Error (ErrorError, "? on area symbol which gets extended later on");
	RESULT.value = Value_Int (value->Data.Symbol.symbol->attr.area->curIdx, eIntType_PureInt);
      }
    else
      {
	ExprScanner_Report2 ("Undefined symbol", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_LOWERCASE(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	RESULT.value = Value_Copy (value); // FIXME: for owning string, we don't need to do this.
	unsigned char *str = (unsigned char *)RESULT.value.Data.String.s;
	for (size_t i = 0; i != RESULT.value.Data.String.len; ++i)
	  str[i] = tolower (str[i]);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':LOWERCASE:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_UPPERCASE(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	RESULT.value = Value_Copy (value); // FIXME: for owning string, we don't need to do this.
	unsigned char *str = (unsigned char *)RESULT.value.Data.String.s;
	for (size_t i = 0; i != RESULT.value.Data.String.len; ++i)
	  str[i] = toupper (str[i]);
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':UPPERCASE:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_REVCC(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	unsigned ccode = GetCCode (value->Data.String.s, value->Data.String.len);
	if (ccode == UINT_MAX)
	  {
	//    Error (ErrorError, "Condition code %.*s is not known",
	//	   (int)value->Data.String.len, value->Data.String.s); FIXME:
	    yy_parse_failed (yypParser);
	  }
	else
	  {
	    unsigned revCCode = ccode ^ 1;
	    unsigned isUpcase = (value->Data.String.len ? (value->Data.String.s[0] & 0x20) : 0) ^ 0x20;
	    /* Input string length is 0 or 2.  */
	    char *str;
	    if ((str = malloc (2)) == NULL)
	      Error_OutOfMem ();
	    str[0] = oLowcaseCCodes[revCCode*2 + 0] ^ isUpcase;
	    str[1] = oLowcaseCCodes[revCCode*2 + 1] ^ isUpcase;
	    RESULT.value = Value_String (str, 2, true);
	  }
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':REVERSE_CC:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_CCENC(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueString)
      {
	unsigned ccode = GetCCode (value->Data.String.s, value->Data.String.len);
	if (ccode == UINT_MAX)
	  {
	//    Error (ErrorError, "Condition code %.*s is not known",
	//	   (int)value->Data.String.len, value->Data.String.s); FIXME:
	    yy_parse_failed (yypParser);
	  }
	else
	  {
	    if (ccode >= 16)
	      ccode += -16 + 2;
	    RESULT.value = Value_Int (ccode << 28, eIntType_PureInt);
	  }
      }
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':CC_ENCODING:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_RCONST(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueInt && value->Data.Int.type != eIntType_PureInt)
      RESULT.value = Value_Int (value->Data.Int.i, eIntType_PureInt);
    else
      {
	ExprScanner_Report2 ("Bad operand type for ':RCONST:'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_DEF(OP) expr_symbol(SRC).
  {
    const Value *value = &SRC.value;

    assert (value->Tag == ValueSymbol);
    /* :DEF: only returns {TRUE} when the symbol is defined and it is
       not a macro local variable.  */
    const Symbol *symP = value->Data.Symbol.symbol;
    RESULT.value = Value_Bool (symP != NULL && !(symP->attr.type & SYMBOL_MACRO_LOCAL));
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_ADD(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    if (value->Tag == ValueInt || value->Tag == ValueInt64 || value->Tag == ValueFloat)
      RESULT.value = *value;
    else
      {
	ExprScanner_Report2 ("Bad operand type for '+'", &OP.pos, &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

expr(RESULT) ::= OP_SUB(OP) expr(SRC).
  {
    const Value *value = &SRC.value;

    uint32_t i;
    if (GetInt (value, &i))
      RESULT.value = Value_Int (-i, eIntType_PureInt);
    else if (value->Tag == ValueInt64)
      RESULT.value = Value_Int64 (-value->Data.Int64.i);
    else if (value->Tag == ValueFloat)
      RESULT.value = Value_Float (-value->Data.Float.f);
    else if (value->Tag == ValueSymbol)
      RESULT.value = Value_Symbol (value->Data.Symbol.symbol, -value->Data.Symbol.factor, -value->Data.Symbol.offset);
    else
      {
	ExprScanner_Report1 ("Bad operand type for '-'", &SRC.pos);
	yy_parse_failed (yypParser);
      }
    UpdateTokenPos (&RESULT.pos, &OP.pos, &SRC.pos);
  }

/* Round bracket support.  */
expr(RESULT) ::= OP_RB_OPEN(BL) expr(B) OP_RB_CLOSE(BR).
  {
    RESULT = B;
    UpdateTokenPos (&RESULT.pos, &BL.pos, &BR.pos);
  }

expr(RESULT) ::= expr_symbol(SRC).
  {
    if (Value_ResolveSymbol (&SRC.value, false /* FIXME? (legal & (ValueInt | ValueSymbol)) == ValueInt */))
      {
	ExprScanner_Report1 ("Can't resolve symbol", &SRC.pos);
	yy_parse_failed (yypParser);
      }
    RESULT.pos = SRC.pos;
  }

expr_symbol(RESULT) ::= VALUE_SYMBOL(SRC).
  {
    RESULT.value = SRC.value;
    RESULT.pos = SRC.pos;
  }

expr(RESULT) ::= VALUE(SRC).
  {
    RESULT.value = SRC.value;
    RESULT.pos = SRC.pos;
  }
