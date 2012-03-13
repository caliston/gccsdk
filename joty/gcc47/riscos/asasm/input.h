/*
 * AS an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2001-2012 GCCSDK Developers
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
 * input.h
 */

#ifndef input_header_included
#define input_header_included

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>

#include "global.h"
#include "macros.h"

#define MAX_PREDEFINES 10
extern const char *predefines[MAX_PREDEFINES];
extern int num_predefines;

bool Input_Match (char c, bool spacesToo);
bool Input_MatchKeyword (const char *keyword);
bool Input_MatchKeywordLower (const char *keyword);
bool Input_MatchString (const char *str);
bool Input_MatchStringLower (const char *str);
bool Input_IsEndOfKeyword (void);

typedef enum
{
  eNoVarSubst,
  eVarSubstNoWarning,
  eVarSubst
} Level_e;

bool Input_NextLine (Level_e level);

void skipblanks (void);

bool Input_IsEolOrCommentStart (void);
char inputLook (void);
char inputLookLower (void);
char inputLookN (int n);
char inputLookNLower (int n);
char inputGet (void);
char inputGetLower (void);
void inputUnGet (char c);
char inputSkipLook (void);
const char *Input_Rest (void);
#if DEBUG
const char *inputLine (void);
#endif
void inputSkip (void);
void inputSkipN (int n);

char *Input_GetString (size_t *len);

const char *Input_Symbol (size_t *ilen);
const char *inputSymbol (size_t *ilen, char del);

const char *Input_GetMark (void);
void Input_RollBackToMark (const char *mark);

void Input_ShowLine (void);
size_t Input_GetColumn (void);

void Input_ThisInstead (const char *);

#endif