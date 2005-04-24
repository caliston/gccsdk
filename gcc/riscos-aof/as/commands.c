/*
 * AS an assembler for ARM
 * Copyright � 1992 Niklas R�jemo, 1997 Darren Salt
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
 * commands.c
 */

#include "config.h"
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#ifdef HAVE_STDINT_H
#include <stdint.h>
#elif HAVE_INTTYPES_H
#include <inttypes.h>
#endif

#include "area.h"
#include "code.h"
#include "commands.h"
#include "decode.h"
#include "depend.h"
#include "error.h"
#include "expr.h"
#include "filestack.h"
#include "fix.h"
#include "hash.h"
#include "help_lex.h"
#include "include.h"
#include "input.h"
#include "lex.h"
#include "lit.h"
#include "local.h"
#include "macros.h"
#include "main.h"
#include "os.h"
#include "output.h"
#include "put.h"
#include "symbol.h"
#include "value.h"

static Symbol *
c_define (const char *msg, Symbol * sym, ValueTag legal)
{
  Value value;

  if (!sym)
    error (ErrorError, FALSE, "Missing label before %s", msg);
  sym->type |= SYMBOL_ABSOLUTE;
  exprBuild ();
  value = exprEval (legal);
  if (value.Tag.t == ValueIllegal)
    {
      error (ErrorError, TRUE, "Illegal %s", msg);
      sym->value.Tag.t = ValueInt;
      sym->value.ValueInt.i = 0;
    }
  else
    sym->value = valueCopy (value);
  sym->type |= SYMBOL_DEFINED;
  sym->declared = 1;
  sym->area.ptr = 0;
  return sym;
}


void
c_equ (Symbol * symbol)
{
  (void) c_define ("equ", symbol, ValueAll);
}


void
c_fn (Symbol * symbol)
{
  int no = c_define ("float register", symbol, ValueInt)->value.ValueInt.i;
  symbol->type |= SYMBOL_FPUREG;
  if (no < 0 || no > 7)
    {
      symbol->value.ValueInt.i = 0;
      error (ErrorError, TRUE, "Illegal %s register %d (using 0)", "fpu", no);
    }
}


void
c_rn (Symbol * symbol)
{
  int no = c_define ("register", symbol, ValueInt)->value.ValueInt.i;
  symbol->type |= SYMBOL_CPUREG;
  if (no < 0 || no > 15)
    {
      symbol->value.ValueInt.i = 0;
      error (ErrorError, TRUE, "Illegal %s register %d (using 0)", "cpu", no);
    }
}


void
c_cn (Symbol * symbol)
{
  int no = c_define ("coprocessor register", symbol, ValueInt)->value.ValueInt.i;
  symbol->type |= SYMBOL_COPREG;
  if (no < 0 || no > 15)
    {
      symbol->value.ValueInt.i = 0;
      error (ErrorError, TRUE, "Illegal %s register %d (using 0)", "cop", no);
    }
}

void
c_cp (Symbol * symbol)
{
  int no = c_define ("coprocessor number", symbol, ValueInt)->value.ValueInt.i;
  symbol->type |= SYMBOL_COPNUM;
  if (no < 0 || no > 15)
    {
      symbol->value.ValueInt.i = 0;
      error (ErrorError, TRUE, "Illegal coprocessor number %d (using 0)", no);
    }
}


void
c_ltorg (void)
{
  if (areaCurrent)
    litOrg (areaCurrent->area.info->lits);
  else
    areaError ();
}


static void
defineint (int size)
{
  Value value;
  WORD word = 0;
  int c;
  do
    {
      skipblanks ();
      exprBuild ();
      value = exprEval (ValueInt | ValueString | ValueCode | ValueLateLabel | ValueAddr);
      switch (value.Tag.t)
	{
	case ValueInt:
	case ValueAddr:
	  word = fixInt (inputLineNo, size, value.ValueInt.i);
	  putData (size, word);
	  break;
	case ValueString:
	  if (size == 1)
	    {			/* Lay out a string */
	      int len = value.ValueString.len;
	      const char *str = value.ValueString.s;
	      while (len > 0)
		putData (1, lexGetCharFromString (&len, &str));
	    }
	  else
	    putData (size, lexChar2Int (FALSE, value.ValueString.len, value.ValueString.s));
	  break;
	case ValueCode:
	case ValueLateLabel:
	  relocInt (size, value);
	  putData (size, word);
	  break;
	default:
	  error (ErrorError, TRUE, "Illegal %s expression", "int");
	  break;
	}
      skipblanks ();
    }
  while (((c = inputGet ()) != 0) && c == ',');
  inputUnGet (c);
}


void
c_head (void)
{
  int i;
  Value value;

  i = areaCurrent ? areaCurrent->value.ValueInt.i : 0;
  skipblanks ();
  exprBuild ();
  value = exprEval (ValueString);
  switch (value.Tag.t)
    {
    case ValueString:
      if (areaCurrent)
	{
	  int len = value.ValueString.len;
	  const char *str = value.ValueString.s;
	  while (len > 0)
	    putData (1, lexGetCharFromString (&len, &str));
	  putData (1, 0);
	}
      break;
    default:
      error (ErrorError, TRUE, "Illegal %s expression", "string");
      break;
    }
  if (areaCurrent)
    {
      while (areaCurrent->value.ValueInt.i & 3)
	areaCurrent->area.info->image[areaCurrent->value.ValueInt.i++] = 0;
      putData (4, 0xFF000000 + (areaCurrent->value.ValueInt.i - i));
    }
  else
    areaError ();
}


void
c_dcb (void)
{
  defineint (1);
}


void
c_dcw (void)
{
  defineint (2);
}


void
c_dcd (void)
{
  defineint (4);
}

static void
definereal (int size)
{
  Value value;
  int c;
  do
    {
      skipblanks ();
      exprBuild ();
      value = exprEval (ValueInt | ValueFloat | ValueLateLabel | ValueCode);
      switch (value.Tag.t)
	{
	case ValueInt:
	  putDataFloat (size, (FLOAT) value.ValueInt.i);
	  break;
	case ValueFloat:
	  putDataFloat (size, value.ValueFloat.f);
	  break;
	case ValueCode:
	case ValueLateLabel:
	  relocFloat (size, value);
	  putDataFloat (size, 0.0);
	  break;
	default:
	  error (ErrorError, TRUE, "Illegal %s expression", "float");
	  break;
	}
      skipblanks ();
    }
  while (((c = inputGet ()) != 0) && c == ',');
  inputUnGet (c);
}


void
c_dcfd (void)
{
  definereal (8);
}


void
c_dcfe (void)
{
  error (ErrorError, FALSE, "Not implemented: dcf%c %s", 'e', inputRest ());
}


void
c_dcfs (void)
{
  definereal (4);
}


void
c_dcfp (void)
{
  error (ErrorError, FALSE, "Not implemented: dcf%c %s", 'p', inputRest ());
}


static void
symFlag (int flag, int declared, const char *err)
{
  Symbol *sym;
  Lex lex = lexGetId ();
  if (lex.tag != LexId)
    return;
  sym = symbolGet (lex);
  if (localTest (sym->str))
    error (ErrorError, TRUE, "Local labels cannot be %s", err);
  else
    {
      sym->type |= flag;
      if (declared)
	sym->declared = 1;
    }
}


void
c_globl (void)
{
  symFlag (SYMBOL_REFERENCE, 1, "exported");
}


void
c_strong (void)
{
  symFlag (SYMBOL_STRONG, 0, "marked 'strong'");
}


void
c_keep (void)
{
  symFlag (SYMBOL_KEEP, 1, "marked 'keep'");
}


void
c_import (void)
{
  int c;
  Symbol *sym;
  Lex lex = lexGetId ();
  if (lex.tag != LexId)
    return;
  sym = symbolGet (lex);
  sym->type |= SYMBOL_REFERENCE;
  sym->declared = 1;
  if ((c = inputGet ()) == ',')
    {
      Lex attribute = lexGetId ();
      if (!strncmp ("WEAK", attribute.LexId.str, attribute.LexId.len))
	sym->type |= SYMBOL_WEAK;
      else
	error (ErrorError, TRUE, "Illegal IMPORT attribute %s", attribute.LexId.str);
    }
}


void
c_get (void)
{
  char *filename, *cptr;
  FILE *getfp;
  const char *newInputName;

  if (macroSP)
    {
      error (ErrorSerious, TRUE, "Cannot use GET within a macro");
      skiprest ();
      return;
    }
  inputExpand = FALSE;
  if ((filename = strdup (inputRest ())) == NULL)
    errorOutOfMem ("c_get");
  for (cptr = filename; *cptr && !isspace (*cptr); cptr++);
  if (*cptr)
    {
      *cptr++ = '\0';		/* must be a space */
      while (*cptr && isspace (*cptr))
	cptr++;
      if (*cptr && *cptr != ';' && (!gcc_backend || *cptr != '@'))
	{
	  error (ErrorError, FALSE, "Skipping extra characters '%s' after filename", cptr);
	}
    }
  if ((getfp = getInclude (filename, "r", &newInputName)) == NULL)
    {
      error (ErrorError, TRUE, "Cannot open file \"%s\"", filename);
      free (filename);
      free ((void *)newInputName);
      return;
    }
  push_file (asmfile);
  inputLineNo = 0;
  inputName = newInputName;
#ifndef CROSS_COMPILE
  dependWrite (filename);
#endif
  asmfile = getfp;
  if (verbose)
    fprintf (stderr, "Including file \"%s\" as \"%s\"\n", filename, inputName);
}


void
c_lnk (void)
{
  char *filename, *cptr;
  FILE *lnkfp;
  const char *newInputName;

  if (macroSP)
    {
      error (ErrorSerious, TRUE, "Cannot use LNK within a macro");
      skiprest ();
      return;
    }
  inputExpand = FALSE;
  if (if_depth)
    if_depth--;
  testUnmatched ();
  if ((filename = strdup (inputRest ())) == NULL)
    errorOutOfMem ("c_lnk");
#ifndef CROSS_COMPILE
  dependWrite (filename);
#endif
  for (cptr = filename; *cptr && !isspace (*cptr); cptr++);
  *cptr = '\0';
  inputNextLine ();
  lnkfp = getInclude (filename, "r", &newInputName);
  if (!lnkfp)
    {
      error (ErrorError, TRUE, "Cannot open file \"%s\"", filename);
      free (filename);
      free ((void *)newInputName);
      return;
    }
  skiprest ();
  inputFinish ();
  inputLineNo = 0;
  inputName = newInputName;
  if_depth = 0;
  asmfile = lnkfp;
  if (verbose)
    fprintf (stderr, "Linking to file \"%s\" as \"%s\"\n", filename, inputName);
}


void
c_idfn (void)
{
  if ((idfn_text = strdup (inputRest ())) == NULL)
    errorOutOfMem("c_idfn");
  skiprest ();
}


void
c_bin (void)
{
  char *filename, *cptr;
  FILE *binfp;
  const char *newFilename;

  inputExpand = FALSE;
  if ((filename = strdup (inputRest ())) == NULL)
    errorOutOfMem ("c_bin");
  for (cptr = filename; *cptr && !isspace (*cptr); cptr++);
  *cptr = '\0';

  binfp = getInclude (filename, "r", &newFilename);
  if (!binfp)
    {
      error (ErrorError, TRUE, "Cannot open file \"%s\"", filename);
      free (filename);
      free ((void *)newFilename);
      return;
    }
  if (verbose)
    fprintf (stderr, "Including binary file \"%s\" as \"%s\"\n", filename, newFilename);
  free ((void *)newFilename);
  while (!feof (binfp))
    putData (1, getc (binfp));
  fclose (binfp);
}


void
c_end (void)
{
  FILE *fp;

  if (macroCurrent)
    {
      error (ErrorSerious, TRUE, "Cannot use END within a macro");
      return;
    }
  fp = pop_file ();
  if (!fp)
    returnvalue = 1;
  else
    {
      fclose (asmfile);
      asmfile = fp;
      if (verbose)
	fprintf (stderr, "Returning from include file\n");
    }
}


void
c_assert (void)
{
  Value value;

  exprBuild ();
  value = exprEval (ValueBool);
  if (value.Tag.t != ValueBool)
    error (ErrorError, TRUE, "ASSERT expression must be boolean");
  else if (!value.ValueBool.b)
    error (ErrorError, TRUE, "Assertion failed");
}
