/*
 * AS an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2000-2010 GCCSDK Developers
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
 * lex.c
 */

#include "config.h"

#include <ctype.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#ifdef HAVE_STDINT_H
#  include <stdint.h>
#elif HAVE_INTTYPES_H
#  include <inttypes.h>
#endif

#include "area.h"
#include "error.h"
#include "help_lex.h"
#include "input.h"
#include "lex.h"
#include "lexAcorn.h"
#include "local.h"
#include "main.h"
#include "os.h"
#include "symbol.h"

const char Pri[2][10] =
{
  {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},	/* AS */
  {1, 2, 3, 4, 10, 5, 6, 7, 8, 9}	/* ObjAsm? */
};

static Lex nextbinop;
static bool nextbinopvalid = false;

/**
 * A simple and fast generic string hasher based on Peter K. Pearson's
 * article in CACM 33-6, pp. 677.
 * \param s string to hash
 * \param maxn maximum number of chars to consider
 */
static unsigned int
lexHashStr (const char *s, size_t maxn)
{
  static const unsigned char hashtab[256] =
  {
    1, 87, 49, 12, 176, 178, 102, 166, 121, 193, 6, 84, 249, 230, 44, 163,
    14, 197, 213, 181, 161, 85, 218, 80, 64, 239, 24, 226, 236, 142, 38, 200,
    110, 177, 104, 103, 141, 253, 255, 50, 77, 101, 81, 18, 45, 96, 31, 222,
    25, 107, 190, 70, 86, 237, 240, 34, 72, 242, 20, 214, 244, 227, 149, 235,
    97, 234, 57, 22, 60, 250, 82, 175, 208, 5, 127, 199, 111, 62, 135, 248,
    174, 169, 211, 58, 66, 154, 106, 195, 245, 171, 17, 187, 182, 179, 0, 243,
    132, 56, 148, 75, 128, 133, 158, 100, 130, 126, 91, 13, 153, 246, 216, 219,
    119, 68, 223, 78, 83, 88, 201, 99, 122, 11, 92, 32, 136, 114, 52, 10,
    138, 30, 48, 183, 156, 35, 61, 26, 143, 74, 251, 94, 129, 162, 63, 152,
    170, 7, 115, 167, 241, 206, 3, 150, 55, 59, 151, 220, 90, 53, 23, 131,
    125, 173, 15, 238, 79, 95, 89, 16, 105, 137, 225, 224, 217, 160, 37, 123,
    118, 73, 2, 157, 46, 116, 9, 145, 134, 228, 207, 212, 202, 215, 69, 229,
    27, 188, 67, 124, 168, 252, 42, 4, 29, 108, 21, 247, 19, 205, 39, 203,
    233, 40, 186, 147, 198, 192, 155, 33, 164, 191, 98, 204, 165, 180, 117, 76,
    140, 36, 210, 172, 41, 54, 159, 8, 185, 232, 113, 196, 231, 47, 146, 120,
    51, 65, 28, 144, 254, 221, 93, 189, 194, 139, 112, 43, 71, 109, 184, 209,
  };

  const unsigned char *p;
  unsigned char h = 0;
  size_t i;
  for (i = 0, p = (const unsigned char *)s; *p && i < maxn; i++, p++)
    h = hashtab[h ^ *p];

  unsigned int rh = h;

  if (SYMBOL_TABLESIZE > 256 && *s)
    {
      for (i = 1, p = (const unsigned char *)s, h = (*p++ + 1) & 0xff;
	   *p && i < maxn; i++, p++)
	h = hashtab[h ^ *p];

      rh <<= 8;
      rh |= h;
    }
  return rh % SYMBOL_TABLESIZE;
}


static int
lexint (int base)
{
  if (base != 16)
    {
      char c;
      if ((c = inputLook ()) == '0')
	{
	  if ((c = inputSkipLook ()) == 'x' || c == 'X')
	    {
	      base = 16;
	      inputSkip ();
	    }
	}
      else
	{
	  if (inputLookN (1) == '_')
	    {
	      inputSkipN (2);
	      if ((base = c - '0') < 2 || base > 9)
		error (ErrorError, "Illegal base %d", base);
	    }
	}
    }

  int res;
  char c;
  for (res = 0; isxdigit (c = inputLookLower ()); inputSkip ())
    {
      c -= (c >= 'a') ? 'a' - 10 : '0';

      if (c >= base)
	return res;

      res = res * base + c;
    }

  return res;
}


Lex
lexGetIdNoError (void)
{
  nextbinopvalid = false;

  skipblanks ();

  Lex result;
  if ((result.Data.Id.str = Input_Symbol (&result.Data.Id.len)) != NULL)
    {
      result.tag = LexId;
      result.Data.Id.hash = lexHashStr (result.Data.Id.str, result.Data.Id.len);
    }
  else
    result.tag = LexNone;

  return result;
}


Lex
lexGetId (void)
{
  Lex result = lexGetIdNoError ();
  if (result.tag != LexId)
    error (ErrorError, "Missing or wrong identifier");
  return result;
}


/**
 * \return -1 when it wasn't able to read a local label, otherwise a local
 * label value 0 - 99 (incl).
 */
static int
Lex_ReadLocalLabel (bool noCheck)
{
  if (!isdigit (inputLook ()))
    errorAbort ("Missing local label number");
  int label = inputGet () - '0';
  if (isdigit (inputLook ()))
    label = 10*label + inputGet () - '0';

  /* If a routinename is given, check if thats the one given with ROUT.  */
  size_t len;
  const char *name = inputSymbol (&len, 0);
  if (!noCheck
      && len
      && !(!memcmp (Local_CurROUTId, name, len) && Local_CurROUTId[len] == '\0'))
    {
      if (Local_ROUTIsEmpty (Local_CurROUTId))
	error (ErrorError, "Local label can not have a routine name %.*s here", (int)len, name);
      else
        error (ErrorError, "Local label with routine name %.*s does not match with current routine name %s", (int)len, name, Local_CurROUTId);
      return -1;
    }

  return label;
}

typedef enum
{
  eThisLevelOnly,
  eAllLevels,
  eThisLevelAndHigher
} LocalLabel_eSearch;

static Lex
Lex_MakeLocalLabel (int dir, LocalLabel_eSearch level)
{
  Lex result =
    {
      .tag = LexNone
    };

  int label = Lex_ReadLocalLabel (false);
  if (label < 0)
    return result;

  int i;
  switch (dir)
    {
      case -1:
	/* Search backward.  */
        if ((i = Local_ROUTLblNo[label] - 1) < 0)
	  {
	    errorAbort ("Missing local label %%b%02i", label);
	    return result;
	  }
        break;

      default:
      case 0:
	/* Search backward, when not found, search forward.  */
        if ((i = Local_ROUTLblNo[label] - 1) < 0)
          i++;
        break;

      case 1:
	/* Search forward.  */
        i = Local_ROUTLblNo[label];
        break;
    }
  char id[1024];
  snprintf (id, sizeof (id), Local_IntLabelFormat, areaCurrentSymbol, label, i, Local_CurROUTId);

  result.tag = LexId;
  result.Data.Id.str = strdup (id);
  if (!result.Data.Id.str)
    errorOutOfMem ();
  result.Data.Id.len = strlen (id);
  result.Data.Id.hash = lexHashStr (result.Data.Id.str, result.Data.Id.len);
  return result;
}


Lex
Lex_GetDefiningLabel (bool noCheck)
{
  nextbinopvalid = false; /* FIXME: why would this be necessary ? */

  if (isdigit ((unsigned char)inputLook ()))
    {
      /* Looks like this is a local label.  */
      Lex result =
	{
	  .tag = LexNone
	};

      int label = Lex_ReadLocalLabel (noCheck);
      if (label < 0)
	return result;

      char id[1024];
      snprintf (id, sizeof (id), Local_IntLabelFormat, areaCurrentSymbol, label, Local_ROUTLblNo[label], Local_CurROUTId);
      Local_ROUTLblNo[label]++;

      result.tag = LexId;
      result.Data.Id.str = strdup (id);
      if (!result.Data.Id.str)
	errorOutOfMem ();
      result.Data.Id.len = strlen (id);
      result.Data.Id.hash = lexHashStr (result.Data.Id.str, result.Data.Id.len);
      return result;
    }

  return lexGetId ();
}


Lex
lexGetPrim (void)
{
  Lex result;

  nextbinopvalid = false;
  skipblanks ();
  char c;
  switch (c = inputGet ())
    {
    case '+':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_none; /* +XYZ */
      result.Data.Operator.pri = PRI (10);
      break;

    case '-':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_neg; /* -XYZ */
      result.Data.Operator.pri = PRI (10);
      break;

    case '!':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_lnot; /* !XYZ */
      result.Data.Operator.pri = PRI (10);
      break;

    case '~':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_not; /* ~XYZ */
      result.Data.Operator.pri = PRI (10);
      break;

    case '?':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_size; /* ?<label> */
      result.Data.Operator.pri = PRI (10);
      break;

    case '(':
    case ')':
      result.tag = LexDelim;
      result.Data.Delim.delim = c;
      break;

    case ':':
      lexAcornUnop (&result);
      break;

    case '&':
      result.tag = LexInt;
      result.Data.Int.value = lexint (16);
      break;

    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      {
	inputUnGet (c);
	const char *mark = Input_GetMark ();
	result.tag = LexInt;
	result.Data.Int.value = lexint (10);
	if (Input_Match ('.', false))
	  {
	    Input_RollBackToMark (mark);
	    result.tag = LexFloat;
	    char *newMark;
	    result.Data.Float.value = strtod (mark, &newMark);
	    if (newMark == mark)
	      error (ErrorError, "Failed to read floating point value");
	    inputSkipN (newMark - mark);
	  }
      }
      break;

    case '\'': /* FIXME: test 'abcd' alike integers.  */
      {
        result.tag = LexInt;
	size_t len;
        const char *str = inputSymbol (&len, '\'');
        if (inputGet () != '\'')
	  error (ErrorError, "Character continues over newline");
        result.Data.Int.value = lexChar2Int (true, len, str);
      }
      break;

    case '"':
      {
        result.tag = LexString;
        size_t len;
        const char *strOrg = inputSymbol (&len, '"');
        char *str;
        if ((str = strndup (strOrg, len)) == NULL)
	  errorOutOfMem();
        if (inputGet () != '"')
	error (ErrorError, "String continues over newline");
	  const char *s1;
	  char *s2;
	  size_t l1;
	  while (Input_Match ('"', false))
	    {
	      s1 = inputSymbol (&l1, '"');
	      if (inputGet () != '"')
		{
		  error (ErrorError, "String continues over newline");
		  break;
		}
	      if ((s2 = malloc (len + l1 + 1)) == NULL)
		errorOutOfMem ();
	      memcpy (s2, str, len);
	      s2[len] = '"';
	      memcpy (s2 + len + 1, s1, l1);
	      free ((void *)str);
	      str = s2;
	      len += l1 + 1;
	    }
	  /* now deal with \\ */
	  s1 = s2 = str;
	  while (*s1)
	    {
	      if (*s1 == '\\')
		{
		  switch (l1 = *++s1)
		    {
		    case '0':
		    case '1':
		    case '2':
		    case '3':
		    case '4':
		    case '5':
		    case '6':
		    case '7':
		      l1 = *s1++ - '0';
		      if (*s1 >= '0' && *s1 <= '7')
			{
			  l1 = l1 * 8 + *s1++ - '0';
			  if (*s1 >= '0' && *s1 <= '7')
			    l1 = l1 * 8 + *s1++ - '0';
			}
		      break;
		    case 'x':
		      if (isxdigit (*++s1))
			{	/* implied ASCII-like */
			  l1 = *s1 - '0' - 7 * (*s1 > '9') - 32 * (*s1 >= 'a');
			  if (isxdigit (*++s1))
			    {
			      l1 = l1 * 16 + *s1 - '0' - 7 * (*s1 > '9') - 32 * (*s1 >= 'a');
			      s1++;
			    }
			}
		      break;
		    case 'a':
		      l1 = 7;
		      s1++;
		      break;
		    case 'b':
		      l1 = 8;
		      s1++;
		      break;
		    case 'f':
		      l1 = 12;
		      s1++;
		      break;
		    case 'n':
		      l1 = 10;
		      s1++;
		      break;
		    case 'r':
		      l1 = 13;
		      s1++;
		      break;
		    case 't':
		      l1 = 9;
		      s1++;
		      break;
		    case 'v':
		      l1 = 11;
		      s1++;
		      break;
		    default:
		      s1++;
		      break;
		    }
		  *s2++ = l1;
		}
	      else
		*s2++ = *s1++;
	    }
	  *s2 = 0;
	  len -= s1 - s2;
	  str = realloc (str, len);	/* try to reduce size of block */
        result.Data.String.str = str;
        result.Data.String.len = len;
      }
      break;

    case '.':
      {
	/* Do we have the position mark '.' or start of floating point number ? */
	if (isdigit ((unsigned char)inputLook ()))
	  {
	    /* Looks like a floating point number.  */
	    inputUnGet (c);
	    const char *mark = Input_GetMark ();
	    result.tag = LexFloat;
	    char *newMark;
	    result.Data.Float.value = strtod (mark, &newMark);
	    if (newMark == mark)
	      error (ErrorError, "Failed to read floating point value");
	    inputSkipN (newMark - mark);
	  }
	else
	  result.tag = LexPosition;
      }
      break;

    case '@':
      result.tag = LexStorage;
      break;

    case '%':
      {
	/* Local label reference.  */
	int dir;
	switch (inputLookLower ())
	  {
	    case 'f':
	      /* Forward looking.  */
	      inputSkip ();
	      dir = 1;
	      break;

	    case 'b':
	      /* Backword looking.  */
	      inputSkip ();
	      dir = -1;
	      break;

	    default:
	      /* Search backwards first, then forward.  */
	      dir = 0;
	      break;
	  }
	LocalLabel_eSearch level;
	switch (inputLookLower ())
	  {
	    case 't':
	      /* Only at this macro level.  */
	      inputSkip ();
	      level = eThisLevelOnly;
	      break;

	    case 'a':
	      /* All macro levels.  */
	      inputSkip ();
	      level = eAllLevels;
	      break;

	    default:
	      /* At this macro level and all upper levels.  */
	      level = eThisLevelAndHigher;
	      break;
	  }
	return Lex_MakeLocalLabel (dir, level);
      }
      break;

    case '{':
      lexAcornPrim (&result);
      break;

    default:
      /* Try to read a symbol.  */
      inputUnGet (c);
      if ((result.Data.Id.str = Input_Symbol (&result.Data.Id.len)) != NULL)
	{
	  result.Data.Id.hash = lexHashStr (result.Data.Id.str, result.Data.Id.len);
	  result.tag = LexId;
	}
      else
	result.tag = LexNone;
      break;
    }

  return result;
}

Lex
lexGetBinop (void)
{
  if (nextbinopvalid)
    {
      nextbinopvalid = false;
      return nextbinop;
    }

  skipblanks ();
  Lex result;
  int c;
  switch (c = inputGet ())
    {
    case '*':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_mul; /* * */
      result.Data.Operator.pri = PRI (10);
      break;

    case '/':
      result.tag = LexOperator;
      switch (inputLook ())
	{
	case '=': /* /= */
	  inputSkip ();
	  result.Data.Operator.op = Op_ne;
	  result.Data.Operator.pri = PRI (3); /* /= */
	  break;
	default:
	  result.Data.Operator.op = Op_div; /* / */
	  result.Data.Operator.pri = PRI (10);
	  break;
	}
      break;

    case '%':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_mod; /* % */
      result.Data.Operator.pri = PRI (10);
      break;

    case '+':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_add; /* + */
      result.Data.Operator.pri = PRI (9);
      break;

    case '-':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_sub; /* - */
      result.Data.Operator.pri = PRI (9);
      break;

    case '^':
      result.tag = LexOperator;
      result.Data.Operator.op = Op_xor; /* ^ */
      result.Data.Operator.pri = PRI (6);
      break;

    case '>':
      result.tag = LexOperator;
      switch (inputLook ())
	{
	case '>':
	  result.Data.Operator.pri = PRI (5);
	  if (inputSkipLook () == '>')
	    {
	      inputSkip ();
	      result.Data.Operator.op = Op_asr; /* >>> */
	    }
	  else
	    result.Data.Operator.op = Op_sr; /* >> */
	  break;

	case '=':
	  inputSkip ();
	  result.Data.Operator.op = Op_ge;
	  result.Data.Operator.pri = PRI (4); /* >= */
	  break;

	default:
	  result.Data.Operator.op = Op_gt;
	  result.Data.Operator.pri = PRI (4); /* > */
	  break;
	}
      break;

    case '<':
      result.tag = LexOperator;
      switch (inputLook ())
	{
	case '<':
	  inputSkip ();
	  result.Data.Operator.op = Op_sl; /* << */
	  result.Data.Operator.pri = PRI (5);
	  break;

	case '=':
	  inputSkip ();
	  result.Data.Operator.op = Op_le; /* <= */
	  result.Data.Operator.pri = PRI (4);
	  break;

	case '>':
	  inputSkip ();
	  result.Data.Operator.op = Op_ne; /* <> */
	  result.Data.Operator.pri = PRI (3);
	  break;

	default:
	  result.Data.Operator.op = Op_lt; /* < */
	  result.Data.Operator.pri = PRI (4);
	  break;
	}
      break;

    case '=':
      Input_Match ('=', false); /* Deals with '==' */
      result.tag = LexOperator;
      result.Data.Operator.pri = PRI (3);
      result.Data.Operator.op = Op_eq; /* = == */
      break;

    case '!':
      if (Input_Match ('=', false))
	{
	  result.tag = LexOperator;
	  result.Data.Operator.pri = PRI (3);
	  result.Data.Operator.op = Op_ne; /* != */
	}
      else
	result.tag = LexNone;
      break;

    case '|':
      result.tag = LexOperator;
      if (Input_Match ('|', false))
	{
	  result.Data.Operator.pri = PRI (1);
	  result.Data.Operator.op = Op_lor; /* || */
	}
      else
	{
	  result.Data.Operator.pri = PRI (7);
	  result.Data.Operator.op = Op_or; /* | */
	}
      break;

    case '&':
      result.tag = LexOperator;
      if (Input_Match ('&', false))
	{
	  result.Data.Operator.pri = PRI (2);
	  result.Data.Operator.op = Op_land; /* && */
	}
      else
	{
	  result.Data.Operator.pri = PRI (8);
	  result.Data.Operator.op = Op_and; /* & */
	}
      break;

    case ':':
      lexAcornBinop (&result); /* :XYZ: */
      break;

    default:
      inputUnGet (c);
      result.tag = LexNone;
      break;
    }

  return result;
}

int
lexNextPri ()
{
  if (!nextbinopvalid)
    {
      nextbinop = lexGetBinop ();
      nextbinopvalid = true;
    }
  return (nextbinop.tag == LexOperator) ? nextbinop.Data.Operator.pri : -1;
}

Lex
lexTempLabel (const char *str, size_t len)
{
  const Lex var =
    {
      .tag = LexId,
      .Data.Id = { .str = str, .len = len, .hash = lexHashStr (str, len) }
    };
  return var;
}

#ifdef DEBUG
void
lexPrint (const Lex *lex)
{
  if (lex == NULL)
    {
      printf ("<NULL> ");
      return;
    }
  switch (lex->tag)
    {
      case LexId:
	printf ("Id <%.*s> ", (int)lex->Data.Id.len, lex->Data.Id.str);
	break;
      case LexString:
	printf ("Str <%.*s> ", (int)lex->Data.String.len, lex->Data.String.str);
	break;
      case LexInt:
	printf ("Int <%d> ", lex->Data.Int.value);
	break;
      case LexFloat:
	printf ("Flt <%g> ", lex->Data.Float.value);
	break;
      case LexOperator:
	printf ("Op <%d, %d> ", lex->Data.Operator.op, lex->Data.Operator.pri);
	break;
      case LexPosition:
	printf ("Pos ");
	break;
      case LexStorage:
	printf ("Stor ");
	break;
      case LexDelim:
	printf ("Delim <%d> ", lex->Data.Delim.delim);
	break;
      case Lex00Label:
	printf ("Label <%d> ", lex->Data.Label.value);
	break;
      case LexBool:
	printf("bool <%d> ", lex->Data.Label.value);
	break;
      case LexNone:
	printf ("None ");
	break;
      default:
	printf ("Unknown lex tag 0x%x ", lex->tag);
	break;
    }
}

const char *
OperatorAsStr (Operator op)
{
  static const char * const opStr[] =
    {
      ":FLOAD:",	/* Op_fload */
      ":FEXEC:", 	/* Op_fexec */
      ":FSIZE:",	/* Op_fsize */
      ":FATTR:",	/* Op_fattr */
      ":LNOT:",		/* Op_lnot */
      ":NOT:",		/* Op_not */
      ":NEG:",		/* Op_neg */
      ":NONE:",		/* Op_none */
      ":BASE:",		/* Op_base */
      ":INDEX:",	/* Op_index */
      ":LEN:",		/* Op_len */
      ":STR:",		/* Op_str */
      ":CHR:",		/* Op_chr */
      ":SIZE:",		/* Op_size */
      ":LEFT:",		/* Op_left */
      ":RIGHT:",	/* Op_right */
      ":MUL:",		/* Op_mul */
      ":DIV:",		/* Op_div */
      ":MOD:",		/* Op_mod */
      ":ADD:",		/* Op_add */
      ":SUB:",		/* Op_sub */
      ":CONCAT:",	/* Op_concat */
      ":AND:",		/* Op_and */
      ":OR:",		/* Op_or */
      ":XOR:",		/* Op_xor */
      ":ASR:",		/* Op_asr */
      ":SHR:",		/* Op_sr */
      ":SHL:",		/* Op_sl */
      ":ROR:",		/* Op_ror */
      ":ROL:",		/* Op_rol */
      ":LE:",		/* Op_le */
      ":GE:",		/* Op_ge */
      ":LT:",		/* Op_lt */
      ":GT:",		/* Op_gt */
      ":EQ:",		/* Op_eq */
      ":NE:",		/* Op_ne */
      ":LAND:",		/* Op_land */
      ":LOR:",		/* Op_lor */
    };
  return op >= sizeof (opStr) / sizeof (opStr[0]) ? ":???:" : opStr[op];
}

#endif
