/*
 * AS an assembler for ARM
 * Copyright (c) 2013 GCCSDK Developers
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
 * debug_dwarf.h
 */

#ifndef debug_dwarf_header_included
#define debug_dwarf_header_included

#ifdef HAVE_INTTYPES_H
#  include <inttypes.h>
#elif HAVE_STDINT_H
#  include <stdint.h>
#endif
#include <stdlib.h>

#include "libelf.h"
#include "libdwarf.h"

#include "output.h" /* for shstrtab_t */
#include "symbol.h"

/* For each (code) area.  */
typedef struct
{
  /* For DWARF line debug data.  */
  const char *lastFileNameP;	/** Last filename being marked.  */
  unsigned lastLineNumber;	/** Last linenumber being marked.  */
  uint32_t lastOffset;		/** Last Area offset being marked.  */
  size_t lineDataIdx;
  size_t lineDataSize;
  uint8_t *lineDataBufP;
} DWARF_State_t;

void DWARF_InitializeState (DWARF_State_t *state);
void DWARF_FinalizeState (DWARF_State_t *state);

void DWARF_MarkAs (const Symbol *areaSymP, uint32_t offset,
		   const char *fileNameP, unsigned lineNumber);

typedef struct
{
  Dwarf_P_Debug dwHandle;
  Dwarf_Signed numDWSections;
  Elf *elfHandle;
  size_t symTabScnIdx;
  shstrtab_t *shStrTabDataP;
  Elf32_Word shStrTabSizeForDWARF;
} DWARF_UserState_t;

void DWARF_CreateAreasAndSections (DWARF_UserState_t *dwUserStateP);
void DWARF_OutputSectionData (DWARF_UserState_t *dwUserStateP);
void DWARF_Finish (DWARF_UserState_t *dwUserStateP);

#endif