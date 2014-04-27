/*
 * AsAsm an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2000-2014 GCCSDK Developers
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

#include "config.h"

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "expr-parser.h"
#include "expr-scanner.h"
#include "value.h"

typedef struct
{
  const char *input;
} LexState_t;

static const char *oCurLine; //FIXME:

static void
ExprScanner (unsigned offset, unsigned size, unsigned done)
{
  for (/* */; done < offset; ++done)
    putc (' ', stdout);
  putc ('^', stdout);
  for (/* */; size > 2; --size)
    putc ('-', stdout);
  if (size == 2)
    putc ('^', stdout);
}

void
ExprScanner_Report1 (const char *msg, const TokenPos_t *pos1)
{
  size_t len = strlen (oCurLine);
  assert (pos1->offset + pos1->size <= len || (pos1->size > 0 && pos1->offset + pos1->size <= len + 1));
  bool termZeroRead = pos1->offset + pos1->size == len + 1;

  printf ("Error: %s\n%s\n", msg, oCurLine);
  ExprScanner (pos1->offset, termZeroRead ? pos1->size - 1 : pos1->size, 0);
  printf ("\n");
}

void
ExprScanner_Report2 (const char *msg, const TokenPos_t *pos1,
	     const TokenPos_t *pos2)
{
  size_t len = strlen (oCurLine);
  assert (pos1->offset + pos1->size <= len);
  assert (pos2->offset + pos2->size <= len || (pos2->size > 0 && pos2->offset + pos2->size <= len + 1));
  assert (pos1->offset + pos1->size <= pos2->offset);
  bool termZeroRead2 = pos2->offset + pos2->size == len + 1;

  printf ("Error: %s\n%s\n", msg, oCurLine);
  ExprScanner (pos1->offset, pos1->size, 0);
  ExprScanner (pos2->offset, termZeroRead2 ? pos2->size - 1 : pos2->size, pos1->offset + (pos1->size == 0 ? 1 : pos1->size));
  printf ("\n");
}

/**
 * \return true for error, false otherwise.
 */
static bool
ExprScanner_Scan (LexState_t *state, Value *resultP)
{
  //oCurLine = state->input; // FIXME:

  const char *cursor = state->input;
  const char *marker = NULL;
  void *parserP = ParseAlloc (malloc);
#ifndef NDEBUG
  ParseTrace(stderr, "Test");
#endif
  ParseTerminal_t termValue;
  ParserState_t parseState =
    {
      .resultP = resultP,
      .err = false
    };

  bool err;
  while (1)
    {
      const char * const tokenStart = cursor;
      termValue.pos.offset = cursor - state->input;

/* To push an TOKEN_OP_* token to the parser.  */
#define CP(token) \
  { \
    termValue.value.Tag = ValueIllegal; \
    termValue.pos.size = cursor - tokenStart; \
    Parse (parserP, token, &termValue, &parseState); \
    continue; \
  }
/* To mark the end of the token stream to the parser.  */
#define CPEND() \
  { \
    termValue.value.Tag = ValueIllegal; \
    termValue.pos.size = 0; \
    Parse (parserP, 0, &termValue, &parseState); \
  }
/* To push a ValueSymbol to the parser.  */
#define CPVS(value) \
  { \
    termValue.value = value; \
    termValue.pos.size = cursor - tokenStart; \
    Parse (parserP, TOKEN_VALUE_SYMBOL, &termValue, &parseState); \
    continue; \
  }
/* To push any Value object except ValueSymbol to the parser.  */
#define CPV(value) \
  { \
    termValue.value = value; \
    termValue.pos.size = cursor - tokenStart; \
    Parse (parserP, TOKEN_VALUE, &termValue, &parseState); \
    continue; \
  }

/*!re2c
re2c:define:YYCTYPE = "char";
re2c:define:YYCURSOR = "cursor";
re2c:define:YYMARKER = "marker";
re2c:yyfill:enable = 0;
 */

      if (parseState.err)
	{
	  fprintf(stderr, "XXX Going in error mode in scanner\n");
	  /* Flush the rest of the input line until its end or when a comma
	     is seen.  */
	  while (1)
	    {
/*!re2c
	      "\000" | "," // Expected end of expression.
		{
		  err = true;
		  break;
		}
*/
	    }
	  break;
	}

/*!re2c
      // Operators (alphabeticallly ordered).
      ":AND:"
	{
	  CP(TOKEN_OP_AND);
	}
      ":ASR:"
	{
	  CP(TOKEN_OP_ASR);
	}
      ":BASE:"
	{
	  CP(TOKEN_OP_BASE);
	}
      ":CC:"
	{
	  CP(TOKEN_OP_CONCAT);
	}
      ":CC_ENCODING:"
	{
	  CP(TOKEN_OP_CCENC);
	}
      ":CHR:"
	{
	  CP(TOKEN_OP_CHR);
	}
      ":DEF:"
	{
	  CP(TOKEN_OP_DEF);
	}
      ":EOR:"
	{
	  CP(TOKEN_OP_EOR);
	}
      ":FATTR:"
	{
	  CP(TOKEN_OP_FATTR);
	}
      ":FEXEC:"
	{
	  CP(TOKEN_OP_FEXEC);
	}
      ":FLOAD:"
	{
	  CP(TOKEN_OP_FLOAD);
	}
      ":FSIZE:"
	{
	  CP(TOKEN_OP_FSIZE);
	}
      ":INDEX:"
	{
	  CP(TOKEN_OP_INDEX);
	}
      ":LAND:"
	{
	  CP(TOKEN_OP_LAND);
	}
      ":LEFT:"
	{
	  CP(TOKEN_OP_LEFT);
	}
      ":LEN:"
	{
	  CP(TOKEN_OP_LEN);
	}
      ":LEOR:"
	{
	  CP(TOKEN_OP_LEOR);
	}
      ":LNOT:"
	{
	  CP(TOKEN_OP_LNOT);
	}
      ":LOR:"
	{
	  CP(TOKEN_OP_LOR);
	}
      ":LOWERCASE:"
	{
	  CP(TOKEN_OP_LOWERCASE);
	}
      ":NOT:"
	{
	  CP(TOKEN_OP_NOT);
	}
      ":MOD:"
	{
	  CP(TOKEN_OP_MOD);
	}
      ":OR:"
	{
	  CP(TOKEN_OP_OR);
	}
      ":RCONST:"
	{
	  CP(TOKEN_OP_RCONST);
	}
      ":REVERSE_CC:"
	{
	  CP(TOKEN_OP_REVCC);
	}
      ":RIGHT:"
	{
	  CP(TOKEN_OP_RIGHT);
	}
      ":ROL:"
	{
	  CP(TOKEN_OP_ROL);
	}
      ":ROR:"
	{
	  CP(TOKEN_OP_ROR);
	}
      ":SHL:"
	{
	  CP(TOKEN_OP_SHL);
	}
      ":SHR:"
	{
	  CP(TOKEN_OP_SHR);
	}
      ":STR:"
	{
	  CP(TOKEN_OP_STR);
	}
      ":UPPERCASE:"
	{
	  CP(TOKEN_OP_UPPERCASE);
	}
      "*"
	{
	  CP(TOKEN_OP_MUL);
	}
      "/="
	{
	  CP(TOKEN_OP_NE);
	}
      "/"
	{
	  CP(TOKEN_OP_DIV);
	}
      "%"
	{
	  CP(TOKEN_OP_MOD);
	}
      "+"
	{
	  CP(TOKEN_OP_ADD);
	}
      "-"
	{
	  CP(TOKEN_OP_SUB);
	}
      ">>>"
	{
	  CP(TOKEN_OP_ASR);
	}
      ">>"
	{
	  CP(TOKEN_OP_SHR);
	}
      ">="
	{
	  CP(TOKEN_OP_GE);
	}
      ">"
	{
	  CP(TOKEN_OP_GT);
	}
      "<<"
	{
	  CP(TOKEN_OP_SHL);
	}
      "<="
	{
	  CP(TOKEN_OP_LE);
	}
      "<>"
	{
	  CP(TOKEN_OP_NE);
	}
      "<"
	{
	  CP(TOKEN_OP_LT);
	}
      "="{1,2}
	{
	  CP(TOKEN_OP_EQ);
	}
      "!="
	{
	  CP(TOKEN_OP_NE);
	}
      "||"
	{
	  if (!Parse_CanPushOperandLOR (parserP))
	    goto dbl_bars_symbol;
	  CP(TOKEN_OP_LOR);
	}
      "|"
	{
	  if (!Parse_CanPushOperandLOR (parserP))
	    goto single_bar_symbol;
	  // FIXME: Emit warning that this is deprecated (use :OR: instead) ?
	  CP(TOKEN_OP_OR);
	}
      "&&"
	{
	  CP(TOKEN_OP_LAND);
	}
      "&"
	{
	  CP(TOKEN_OP_AND);
	}
      "^"
	{
	  CP(TOKEN_OP_EOR);
	}

      "!"
	{
	  CP(TOKEN_OP_LNOT);
	}
      "~"
	{
	  CP(TOKEN_OP_NOT);
	}
      "?"
	{
	  CP(TOKEN_OP_SIZE);
	}
      "("
	{
	  CP(TOKEN_OP_RB_OPEN);
	}
      ")"
	{
	  CP(TOKEN_OP_RB_CLOSE);
	}

      // "&" -> hex int FIXME
      // int literal FIXME
      [0-9]+
	{
	  Value value = Value_Int (atoi (tokenStart), eIntType_PureInt); // FIXME: atoi
	  CPV(value);
	}
      // 0f_ 0d_ float literal FIXME
      // 0x literal FIXME

      "'" [0-9]{1,4} "'"
	{
	  Value value = Value_Int (0, eIntType_PureInt); // FIXME !
	  CPV(value);
	}

      "\"" [^"]* "\""
	{
	  Value value = Value_String (tokenStart + 1, cursor - tokenStart - 2, false); // FIXME ! Properly process string at YYCURSOR and update it afterwards.
	  CPV(value);
	}

      "."\[0-9]
	{
	  Value value = Value_Symbol (0, 1, 0); // FIXME ! Same as {PC} Add AreaCurrentSymbol, areaCurrentSymbol->attr.area->curIdx
	  CPVS(value);
	}
      [0-9]* "." [0-9]* // FIXME: floating point format not fully covered.
	{ 
	  Value value = Value_Float (atof (tokenStart)); // FIXME !
	  CPV(value);
	}

      "@"
	{
	  Value value = Value_Int (0, eIntType_PureInt); // FIXME ! Storage_Value()  Same as {VAR}
	  CPV(value);
	}

      "%"
	{
	  CPVS(Value_Symbol (0, 1, 0)); // FIXME ! Lex_MakeReferringLocalLabel
	}

      "{ASASM_VERSION}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{ARCHITECTURE}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{AREANAME}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      // FIXME: {COMMANDLINE}
      "{CODESIZE}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{CONFIG}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{CPU}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{ENDIAN}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{FALSE}"
	{
	  Value value = Value_Bool (false);
	  CPV(value);
	}
      "{FPU}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{INPUTFILE}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{INTER}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{LINENUM}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{LINENUMUP}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{LINENUMUPPER}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{OPT}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      // FIXME: "{PCSTOREOFFSET}"
      "{PC}"
	{
	  Value value = Value_Symbol (0, 1, 0); // FIXME ! Same as "." Add reaCurrentSymbol, areaCurrentSymbol->attr.area->curIdx
	  CPVS(value);
        }
      "{ROPI}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{REENTRANT}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{RWPI}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_ARCH_ARM}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_ARCH_THUMB}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      // FIXME: {TARGET_ARCH_<arch>}
      "{TARGET_FEATURE_CLZ}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_DIVIDE}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_DOUBLEWORD}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_DSPMUL}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_EXTENSION_REGISTER_COUNT}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_MULTIPLY}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_MULTIPROCESSING}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_NEON}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_NEON_FP16}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_NEON_FP32}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_NEON_INTEGER}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FEATURE_UNALIGNED}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_FPA}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_SOFTFPA}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_SOFTFPA_FPA}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_SOFTFPA_VFP}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_SOFTVFP}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_SOFTVFP_FPA}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_SOFTVFP_VFP}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_VFP}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_VFPV1}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_VFPV2}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_VFPV3}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_FPU_VFPV4}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_PROFILE_A}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_PROFILE_M}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TARGET_PROFILE_R}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{TRUE}"
	{
	  Value value = Value_Bool (true);
	  CPV(value);
	}
      "{UAL}"
	{
	  printf ("Error: FIXME\n");
	  err = true;
	  break;
        }
      "{VAR}"
	{
	  Value value = Value_Int (0, eIntType_PureInt); // FIXME ! Storage_Value()  Same as "@"
	  CPV(value);
	}
      "{" [A-Z]* "}"
	{
	  termValue.pos.size = cursor - tokenStart;
	  ExprScanner_Report1 ("Unknown built-in variable", &termValue.pos);
	  err = true;
	  break;
	}

      // Symbol needs to start with a letter (upper- or lowercase), followed by
      // letter, digits and underscore.
      // We do allow an underscore as starting character as well.
      [a-zA-Z_][a-zA-Z_0-9]*
	{
	  printf ("Symbol: %.*s\n", (int)(cursor - tokenStart), tokenStart); // FIXME
	  Value value = Value_Symbol (0, 1, 0); // FIXME
	  CPVS(value);
	}

      [ \t]+ // Whitespace handling.
	{
	  // Nothing to do.
	  continue;
	}
      "\000" | "," // Expected end of expression.
	{
	  CPEND();
	  err = false;
	  break;
	}
      [^]
	{
	  // Unexpected end of expression.
	  termValue.pos.size = cursor - tokenStart;
	  ExprScanner_Report1 ("Unrecognized token", &termValue.pos);
	  err = true;
	  break;
	}
*/

single_bar_symbol:
/*!re2c
      "|"
	{
	  printf ("Symbol: %.*s\n", (int)(cursor - tokenStart), tokenStart); // FIXME
	  assert (tokenStart[0] == '|' && tokenStart[1] == '|' && cursor[-1] == '|' && cursor[-2] == '|');
	  Value value = Value_Symbol (0, 1, 0); // FIXME
	  CPVS(value);
	}
      "\000"
	{
	  // Unexpected end of a double bars symbol.
	  termValue.pos.size = cursor - tokenStart;
	  ExprScanner_Report1 ("Unterminated symbol", &termValue.pos);
	  err = true;
	  break;
	}
      [^]
	{
	  goto single_bar_symbol;
        }
 */

dbl_bars_symbol:
/*!re2c
      "||"
	{
	  printf ("Symbol: %.*s\n", (int)(cursor - tokenStart), tokenStart); // FIXME
	  assert (tokenStart[0] == '|' && tokenStart[1] == '|' && cursor[-1] == '|' && cursor[-2] == '|');
	  Value value = Value_Symbol (0, 1, 0); // FIXME
	  CPVS(value);
	}
      "\000"
	{
	  // Unexpected end of a double bars symbol.
	  termValue.pos.size = cursor - tokenStart;
	  ExprScanner_Report1 ("Unterminated symbol", &termValue.pos);
	  err = true;
	  break;
	}
      [^]
	{
	  goto dbl_bars_symbol;
        }
 */
    }
#ifndef NDEBUG
  ParseTrace(NULL, NULL);
#endif

  ParseFree (parserP, free);
  return err;
}

void
ExprScanner_Test (const char *str)
{
  LexState_t state = { .input = str };
  Value result = { .Tag = ValueIllegal };
  if (ExprScanner_Scan (&state, &result))
    {
      fprintf (stderr, "Lex_Test(): Error...\n");
      assert (result.Tag == ValueIllegal);
    }
  else
    {
      printf ("Lex_Test(): result is ");
#ifdef DEBUG
      Value_Print (&result); printf ("\n");
#endif
      Value_Free (&result);
    }
}
