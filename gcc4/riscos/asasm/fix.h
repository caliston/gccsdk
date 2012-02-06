/*
 * AS an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2004-2012 GCCSDK Developers
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
 * fix.h
 */

#ifndef fix_header_included
#define fix_header_included

#include "global.h"

ARMWord fixImm8s4 (unsigned lineNum, ARMWord ir, int im);
ARMWord fixSwi (unsigned lineNum, int im);
ARMWord fixMask (unsigned lineNum, int mask);

ARMWord Fix_ShiftImm (const char *fileName, unsigned lineNum, ARMWord shiftop, int shift);
ARMWord Fix_Int (const char *fileName, unsigned lineNum, int size, int value);
ARMWord Fix_CopOffset (const char *fileName, unsigned lineNum, ARMWord ir, int offset);
ARMWord Fix_CPUOffset (const char *fileName, unsigned lineNum, ARMWord ir, int offset);
ARMWord Fix_MOV (const char *fileName, unsigned lineNum, ARMWord ir, int im);

#endif
