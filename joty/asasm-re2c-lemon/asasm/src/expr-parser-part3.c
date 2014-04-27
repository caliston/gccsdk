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

/* This file is included by expr-parser.c and not compiled on its own.  */

/**
 * Query can be used to decide if we have a || (i.e. :LOR:) in our scanner
 * or ||symbol|| VALUE_SYMBOL operand.
 * \return false when pushing TOKEN_OP_LOR will result in a parse error.
 */
bool
Parse_CanPushOperandLOR (void *yyp)
{
  yyParser *pParser = (yyParser *)yyp;

  int stateno = pParser->yyidx >= 0 ? pParser->yystack[pParser->yyidx].stateno : 0;
  int action = yy_get_action_for_state (stateno, TOKEN_OP_LOR);
  return action != YY_ERROR_ACTION;
}
