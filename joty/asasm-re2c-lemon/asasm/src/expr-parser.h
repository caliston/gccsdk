/*
 * AsAsm an assembler for ARM
 * Copyright (c) 2014 GCCSDK Developers
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

#ifndef EXPR_PARSER_HEADER_INCLUDED
#define EXPR_PARSER_HEADER_INCLUDED

#include <stdbool.h>
#ifndef NDEBUG
# include <stdio.h>
#endif
#include "value.h"

#include "expr-parser-part2.h"

typedef struct
{
  unsigned offset;
  unsigned size;
} TokenPos_t;

typedef struct
{
  Value value;
  TokenPos_t pos;
} ParseTerminal_t;

typedef struct
{
  Value *resultP; /**< Expression result.  */
  bool err;
} ParserState_t;

/* As Lemon doesn't provide prototypes for these: */
void *ParseAlloc (void *(*)(size_t));
void Parse (void *, int, const ParseTerminal_t *, ParserState_t *);
void ParseFree (void *, void (*)(void*));
#ifndef NDEBUG
void ParseTrace (FILE *TraceFILE, const char *zTracePrompt);
#endif

bool Parse_CanPushOperandLOR (void *yyp);

#endif
