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

#ifndef EXPR_SCANNER_HEADER_INCLUDED
#define EXPR_SCANNER_HEADER_INCLUDED

#include "expr-parser.h"

void ExprScanner_Report1 (const char *msg, const TokenPos_t *pos1);
void ExprScanner_Report2 (const char *msg, const TokenPos_t *pos1,
			  const TokenPos_t *pos2);

void ExprScanner_Test (const char *str);

#endif
