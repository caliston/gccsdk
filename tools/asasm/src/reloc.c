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
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "libelf.h"

#include "aoffile.h"
#include "area.h"
#include "error.h"
#include "expr.h"
#include "global.h"
#include "input.h"
#include "main.h"
#include "phase.h"
#include "reloc.h"
#include "state.h"
#include "symbol.h"
#include "value.h"

typedef struct
{
  const char *name;
  uint8_t value;
} ARM_Reloc_Types;
/* ARM ELF ABI relocation definitions, cfr. "ARM IHI 0044E"
   (30th November 2012).
   Alphabetically sorted.  */
static const ARM_Reloc_Types oARMRelocTypes[] =
{
  { "ABS12", R_ARM_ABS12 },
  { "ABS16", R_ARM_ABS16 },
  { "ABS32", R_ARM_ABS32 },
  { "ABS32_NOI", R_ARM_ABS32_NOI },
  { "ABS8", R_ARM_ABS8 },
  { "ALU_PCREL_15_8", R_ARM_ALU_PCREL_15_8 },
  { "ALU_PCREL_23_15", R_ARM_ALU_PCREL_23_15 },
  { "ALU_PCREL_7_0", R_ARM_ALU_PCREL_7_0 },
  { "ALU_PC_G0", R_ARM_ALU_PC_G0 },
  { "ALU_PC_G0_NC", R_ARM_ALU_PC_G0_NC },
  { "ALU_PC_G1", R_ARM_ALU_PC_G1 },
  { "ALU_PC_G1_NC", R_ARM_ALU_PC_G1_NC },
  { "ALU_PC_G2", R_ARM_ALU_PC_G2 },
  { "ALU_SBREL_19_12_NC", R_ARM_ALU_SBREL_19_12_NC },
  { "ALU_SBREL_27_20_CK", R_ARM_ALU_SBREL_27_20_CK },
  { "ALU_SB_G0", R_ARM_ALU_SB_G0 },
  { "ALU_SB_G0_NC", R_ARM_ALU_SB_G0_NC },
  { "ALU_SB_G1", R_ARM_ALU_SB_G1 },
  { "ALU_SB_G1_NC", R_ARM_ALU_SB_G1_NC },
  { "ALU_SB_G2", R_ARM_ALU_SB_G2 },
  { "BASE_ABS", R_ARM_BASE_ABS },
  { "BASE_PREL", R_ARM_BASE_PREL },
  { "BREL_ADJ", R_ARM_BREL_ADJ },
  { "CALL", R_ARM_CALL },
  { "COPY", R_ARM_COPY },
  { "GLOB_DAT", R_ARM_GLOB_DAT },
  { "GNU_VTENTRY", R_ARM_GNU_VTENTRY },
  { "GNU_VTINHERIT", R_ARM_GNU_VTINHERIT },
  { "GOTOFF12", R_ARM_GOTOFF12 },
  { "GOTOFF32", R_ARM_GOTOFF32 },
  { "GOTRELAX", R_ARM_GOTRELAX },
  { "GOT_ABS", R_ARM_GOT_ABS },
  { "GOT_BREL", R_ARM_GOT_BREL },
  { "GOT_BREL12", R_ARM_GOT_BREL12 },
  { "GOT_PREL", R_ARM_GOT_PREL },
  { "IRELATIVE", R_ARM_IRELATIVE },
  { "JUMP24", R_ARM_JUMP24 },
  { "JUMP_SLOT", R_ARM_JUMP_SLOT },
  { "LDC_PC_G0", R_ARM_LDC_PC_G0 },
  { "LDC_PC_G1", R_ARM_LDC_PC_G1 },
  { "LDC_PC_G2", R_ARM_LDC_PC_G2 },
  { "LDC_SB_G0", R_ARM_LDC_SB_G0 },
  { "LDC_SB_G1", R_ARM_LDC_SB_G1 },
  { "LDC_SB_G2", R_ARM_LDC_SB_G2 },
  { "LDRS_PC_G0", R_ARM_LDRS_PC_G0 },
  { "LDRS_PC_G1", R_ARM_LDRS_PC_G1 },
  { "LDRS_PC_G2", R_ARM_LDRS_PC_G2 },
  { "LDRS_SB_G0", R_ARM_LDRS_SB_G0 },
  { "LDRS_SB_G1", R_ARM_LDRS_SB_G1 },
  { "LDRS_SB_G2", R_ARM_LDRS_SB_G2 },
  { "LDR_PC_G0", R_ARM_LDR_PC_G0 },
  { "LDR_PC_G1", R_ARM_LDR_PC_G1 },
  { "LDR_PC_G2", R_ARM_LDR_PC_G2 },
  { "LDR_SBREL_11_0_NC", R_ARM_LDR_SBREL_11_0_NC },
  { "LDR_SB_G0", R_ARM_LDR_SB_G0 },
  { "LDR_SB_G1", R_ARM_LDR_SB_G1 },
  { "LDR_SB_G2", R_ARM_LDR_SB_G2 },
  { "ME_TOO", R_ARM_ME_TOO },
  { "MOVT_ABS", R_ARM_MOVT_ABS },
  { "MOVT_BREL", R_ARM_MOVT_BREL },
  { "MOVT_PREL", R_ARM_MOVT_PREL },
  { "MOVW_ABS_NC", R_ARM_MOVW_ABS_NC },
  { "MOVW_BREL", R_ARM_MOVW_BREL },
  { "MOVW_BREL_NC", R_ARM_MOVW_BREL_NC },
  { "MOVW_PREL_NC", R_ARM_MOVW_PREL_NC },
  { "NONE", R_ARM_NONE },
  { "PC24", R_ARM_PC24 },
  { "PLT32", R_ARM_PLT32 },
  { "PLT32_ABS", R_ARM_PLT32_ABS },
  { "PREL31", R_ARM_PREL31 },
  { "PRIVATE_0", R_ARM_PRIVATE_0 },
  { "PRIVATE_1", R_ARM_PRIVATE_1 },
  { "PRIVATE_10", R_ARM_PRIVATE_10 },
  { "PRIVATE_11", R_ARM_PRIVATE_11 },
  { "PRIVATE_12", R_ARM_PRIVATE_12 },
  { "PRIVATE_13", R_ARM_PRIVATE_13 },
  { "PRIVATE_14", R_ARM_PRIVATE_14 },
  { "PRIVATE_15", R_ARM_PRIVATE_15 },
  { "PRIVATE_2", R_ARM_PRIVATE_2 },
  { "PRIVATE_3", R_ARM_PRIVATE_3 },
  { "PRIVATE_4", R_ARM_PRIVATE_4 },
  { "PRIVATE_5", R_ARM_PRIVATE_5 },
  { "PRIVATE_6", R_ARM_PRIVATE_6 },
  { "PRIVATE_7", R_ARM_PRIVATE_7 },
  { "PRIVATE_8", R_ARM_PRIVATE_8 },
  { "PRIVATE_9", R_ARM_PRIVATE_9 },
  { "REL32", R_ARM_REL32 },
  { "REL32_NOI", R_ARM_REL32_NOI },
  { "RELATIVE", R_ARM_RELATIVE },
  { "SBREL31", R_ARM_SBREL31 },
  { "SBREL32", R_ARM_SBREL32 },
  { "SWI24", R_ARM_SWI24 },
  { "TARGET1", R_ARM_TARGET1 },
  { "TARGET2", R_ARM_TARGET2 },
  { "THM_ABS5", R_ARM_THM_ABS5 },
  { "THM_ALU_PREL_11_0", R_ARM_THM_ALU_PREL_11_0 },
  { "THM_CALL", R_ARM_THM_CALL },
  { "THM_GOT_BREL12", R_ARM_THM_GOT_BREL12 },
  { "THM_JUMP11", R_ARM_THM_JUMP11 },
  { "THM_JUMP19", R_ARM_THM_JUMP19 },
  { "THM_JUMP24", R_ARM_THM_JUMP24 },
  { "THM_JUMP6", R_ARM_THM_JUMP6 },
  { "THM_JUMP8", R_ARM_THM_JUMP8 },
  { "THM_MOVT_ABS", R_ARM_THM_MOVT_ABS },
  { "THM_MOVT_BREL", R_ARM_THM_MOVT_BREL },
  { "THM_MOVT_PREL", R_ARM_THM_MOVT_PREL },
  { "THM_MOVW_ABS_NC", R_ARM_THM_MOVW_ABS_NC },
  { "THM_MOVW_BREL", R_ARM_THM_MOVW_BREL },
  { "THM_MOVW_BREL_NC", R_ARM_THM_MOVW_BREL_NC },
  { "THM_MOVW_PREL_NC", R_ARM_THM_MOVW_PREL_NC },
  { "THM_PC12", R_ARM_THM_PC12 },
  { "THM_PC8", R_ARM_THM_PC8 },
  { "THM_SWI8", R_ARM_THM_SWI8 },
  { "THM_TLS_CALL", R_ARM_THM_TLS_CALL },
  { "THM_TLS_DESCSEQ16", R_ARM_THM_TLS_DESCSEQ16 },
  { "THM_TLS_DESCSEQ32", R_ARM_THM_TLS_DESCSEQ32 },
  { "THM_XPC22", R_ARM_THM_XPC22 },
  { "TLS_CALL", R_ARM_TLS_CALL },
  { "TLS_DESC", R_ARM_TLS_DESC },
  { "TLS_DESCSEQ", R_ARM_TLS_DESCSEQ },
  { "TLS_DTPMOD32", R_ARM_TLS_DTPMOD32 },
  { "TLS_DTPOFF32", R_ARM_TLS_DTPOFF32 },
  { "TLS_GD32", R_ARM_TLS_GD32 },
  { "TLS_GOTDESC", R_ARM_TLS_GOTDESC },
  { "TLS_IE12GP", R_ARM_TLS_IE12GP },
  { "TLS_IE32", R_ARM_TLS_IE32 },
  { "TLS_LDM32", R_ARM_TLS_LDM32 },
  { "TLS_LDO12", R_ARM_TLS_LDO12 },
  { "TLS_LDO32", R_ARM_TLS_LDO32 },
  { "TLS_LE12", R_ARM_TLS_LE12 },
  { "TLS_LE32", R_ARM_TLS_LE32 },
  { "TLS_TPOFF32", R_ARM_TLS_TPOFF32 },
  { "V4BX", R_ARM_V4BX },
  { "XPC25", R_ARM_XPC25 }
};


void
Reloc_InitializeState (Reloc_State_t *stateP)
{
  stateP->numRelocsInt = 0;
  stateP->maxNumRelocsInt = 0;
  stateP->relocIntP = NULL;
  stateP->offsetForExplicitReloc = UINT32_MAX;
  stateP->raw.rawP = NULL;
}


void
Reloc_FinalizeState (Reloc_State_t *stateP)
{
  free (stateP->relocIntP);
  stateP->relocIntP = NULL;
  free (stateP->raw.rawP);
  stateP->raw.rawP = NULL;
}


/**
 * Splits given value into relocation symbol (if possible) and addend which
 * needs to be encoded in the final instruction.
 *
 * \param valP Value whichs needs to be splitted.
 * \param pcRelSymP When non-NULL, an area symbol which can be used to
 * generate a PC-relative Value_Addr() addend.
 * \param instrOffset Instruction offset.  Used when pcRelSymP is non-NULL to
 * calculate the addend Value_Addr().
 *
 * When RelocAndAddend_t::addend.Tag is ValueIllegal, this routine failed.
 * Otherwise it is the value which needs to be encoded in the instruction.
 * Additionally, when RelocAndAddend_t::relocSymbol.Tag == ValueSymbol,
 * appropriate relocations need to be outputed.  In that case
 * relocSymbol.Data.Symbol.offset is 0 but relocSymbol.Data.Symbol.factor is
 * >= 1.
 */
RelocAndAddend_t
Reloc_SplitRelocAndAddend (const Value *valP, const Symbol *pcRelSymP,
			   uint32_t instrOffset, bool intAddendOk)
{
  assert (pcRelSymP == NULL || (pcRelSymP->attr.type & SYMBOL_AREA) != 0);

  RelocAndAddend_t result =
    {
      .relocSymbol.Tag = ValueIllegal,
      .addend.Tag = ValueIllegal
    };

  if (Value_IsLabel (valP))
    {
      Symbol *symP = valP->Data.Symbol.symbol;
      int symOffset = valP->Data.Symbol.offset;
      int symFactor = valP->Data.Symbol.factor;
      assert ((symP->attr.type & SYMBOL_AREA) != 0);
      const Area *areaP = symP->attr.area;
      assert (areaP != NULL);

      if ((areaP->type & AREA_BASED) != 0)
	{
	  /* Label in an AREA BASED.  */
	  if (symFactor == 1)
	    {
	      result.relocSymbol = Value_Symbol (symP, 1, 0);
	      result.addend = Value_Addr (Area_GetBaseReg (areaP), symOffset);
	    }
	}
      else if ((areaP->type & AREA_ABS) != 0 && intAddendOk)
	{
	  /* Label in an ABS AREA.  */
	  result.relocSymbol.Tag = ValueIllegal;
	  result.addend = Value_Int (symFactor * Area_GetBaseAddress (symP) + symOffset,
	                             eIntType_PureInt);
	}
      else if (pcRelSymP != NULL && symFactor == 1)
	{
	  int pcOffset = State_GetInstrType () == eInstrType_ARM ? 8 : 4;
	  if (symP == pcRelSymP)
	    {
	      result.relocSymbol.Tag = ValueIllegal;
	      result.addend = Value_Addr (15, symOffset - (instrOffset + pcOffset));
	    }
	  else
	    {
	      result.relocSymbol = Value_Symbol (symP, 1, 0);
	      result.addend = Value_Addr (15, symOffset - pcOffset);
	    }
	}
      else if (intAddendOk)
	{
	  result.relocSymbol = Value_Symbol (symP, symFactor, 0);
	  result.addend = Value_Int (symOffset, eIntType_PureInt);
	}
    }
  else if (valP->Tag == ValueSymbol)
    {
      Symbol *symP = valP->Data.Symbol.symbol;
      int symOffset = valP->Data.Symbol.offset;
      int symFactor = valP->Data.Symbol.factor;
      if (symFactor == 1)
	{
	  result.relocSymbol = Value_Symbol (symP, 1, 0);
	  if (symP->attr.value.Tag == ValueAddr)
	    {
	      /* IMPORT ... [ BASED ...] symbols.  */
	      result.addend = symP->attr.value;
	      result.addend.Data.Addr.i += symOffset;
	    }
	  else if (pcRelSymP != NULL)
	    {
	      int pcOffset = State_GetInstrType () == eInstrType_ARM ? 8 : 4;
	      result.addend = Value_Addr (15, symOffset - pcOffset);
	    }
	  else
	    result.addend = Value_Int (symOffset, eIntType_PureInt);
	}
    }
  else if (!intAddendOk
	   && valP->Tag == ValueInt
	   && valP->Data.Int.type == eIntType_PureInt
	   && pcRelSymP != NULL
	   && (pcRelSymP->attr.area->type & AREA_ABS) != 0)
    {
      /* Convert integer (presumebly an address) into ValueAddr.  */
      int pcOffset = State_GetInstrType () == eInstrType_ARM ? 8 : 4;
      int pcVal = Area_GetBaseAddress (pcRelSymP) + instrOffset + pcOffset;
      result.addend = Value_Addr (15, valP->Data.Int.i - pcVal);
    }
  else
    result.addend = *valP;

  /* When at pass 1, result.relocSymbol can contain a relocation symbol
     which gets resolved later at pass 1.
     As we could draw wrong conclusions during that pass 1, we deliberately
     fail for that case.  */
  if (gPhase == ePassOne
      && result.relocSymbol.Tag == ValueSymbol
      && (result.relocSymbol.Data.Symbol.symbol->attr.type & (SYMBOL_DEFINED | SYMBOL_EXPORT | SYMBOL_AREA)) == 0)
    result.addend.Tag = ValueIllegal;

  /* ELF PC-based relocations happen for instructions with base {PC} but
     AOF Type 2 relocations happen for instructions with base <area origin>.
     Note, we're assuming here we're outputing AOF Type 2 and not Type 1
     relocations.  */
  if (option_aof
      && result.relocSymbol.Tag == ValueSymbol
      && result.addend.Tag == ValueAddr
      && result.addend.Data.Addr.r == 15)
    result.addend.Data.Addr.i -= instrOffset;

  return result;
}


/**
 * Adds AOF/ELF relocation for the current area.
 * \param how For AOF these are the HOW2_* bits. HOW2_SYMBOL will get assigned
 * automatically. For ELF, this is a R_ARM_* vaule.
 * \param offset Area offset where the relocation needs to happen.
 * \param value
 *   For AOF A ValueSymbol value.
 *   For ELF A ValueSymbol, ValueInt value or NULL.
 *     In case of ValueInt, a relocation against an absolute value symbol will
 *     be created (same value as the ValueInt).
 *     When NULL, it will be a relocation against anonymous symbol.
 *   For both AOF and ELF and when ValueSymbol, its offset will be ignored and
 *   needs to be taken into account by the caller.
 * \param replace When true, previous relocation(s) for same offset will be
 * replaced by given new relocation.
 */
void
Reloc_CreateInternal (uint32_t how, uint32_t offset, const Value *value,
                      bool replace)
{
  if (gPhase != ePassTwo)
    return;

  /* For ELF output: allow relocations against absolute address.
     I.e. turn ValueInt into a ValueSymbol pointing to a, in ELF terms,
     symbol holding an absolute value (SHN_ABS).  */
  Value absSymValue;
  if (!option_aof && value != NULL && value->Tag == ValueInt)
    {
      /* Use "*ABS*0x" followed by the hex representation of the absolute
	 address.  Same as binutils.  */ // FIXME: Use asasm internal prefix ?
      char symName[16];
      int r = snprintf (symName, sizeof (symName), "*ABS*0x%x", value->Data.Int.i);
      assert (r >= 0 && (size_t)r < sizeof (symName));
      Symbol *absSymP = Symbol_Get (symName, r);
      /* SYMBOL_KEEP to force it being outputed.  */
      if (Symbol_Define (absSymP, SYMBOL_ABSOLUTE | SYMBOL_KEEP, value))
	return; /* We don't expect this to be happening.  */
      absSymValue = Value_Symbol (absSymP, 1, 0);
      value = &absSymValue;
    }

  assert ((value == NULL && !option_aof) || (value != NULL && value->Tag == ValueSymbol && value->Data.Symbol.factor > 0));
  assert ((value == NULL && !option_aof) || (value != NULL && !Area_IsMappingSymbol (value->Data.Symbol.symbol->str)));

  assert ((option_aof && (how & HOW2_SIDMASK) == 0) || (!option_aof && how < 256u));
  assert (offset <= areaCurrentSymbol->attr.area->curIdx + 3);

  Reloc_State_t *stateP = &areaCurrentSymbol->attr.area->reloc;
  Symbol *relocSymP = value ? value->Data.Symbol.symbol : NULL;
  size_t entriesNeeded = value ? value->Data.Symbol.factor : 1;
  if (replace)
    {
      /* Rollback relocations having the same offset.  */
      while (stateP->numRelocsInt
             && stateP->relocIntP[stateP->numRelocsInt - 1].offset == offset)
	{
	  /* When replacing a relocation and no relocation symbol is given,
	     we're only updating the relocation name.
	     FIXME: is undefined behavior  when more than one relocation
	     symbol needs to be applied for same offset.  */
	  if (relocSymP == NULL)
	    relocSymP = stateP->relocIntP[stateP->numRelocsInt - 1].symP;
	  --stateP->numRelocsInt;
	}
    }
  assert (stateP->numRelocsInt == 0 || offset >= stateP->relocIntP[stateP->numRelocsInt - 1].offset);
  if (stateP->numRelocsInt + entriesNeeded > stateP->maxNumRelocsInt)
    {
      size_t newMaxNumRelocsInt = stateP->maxNumRelocsInt ? 2*stateP->maxNumRelocsInt : 16;
      if (stateP->numRelocsInt + entriesNeeded > newMaxNumRelocsInt)
	newMaxNumRelocsInt = stateP->numRelocsInt + entriesNeeded;
      struct RelocInt *newRelocsIntP;
      if ((newRelocsIntP = realloc (stateP->relocIntP, newMaxNumRelocsInt * sizeof (struct RelocInt))) == NULL)
	Error_OutOfMem ();
      stateP->maxNumRelocsInt = newMaxNumRelocsInt;
      stateP->relocIntP = newRelocsIntP;
    }
  while (entriesNeeded--)
    {
      stateP->relocIntP[stateP->numRelocsInt].how = how;
      stateP->relocIntP[stateP->numRelocsInt].offset = offset;
      stateP->relocIntP[stateP->numRelocsInt].symP = relocSymP;
      ++stateP->numRelocsInt;
    }

  /* Mark we want this symbol in the output symbol table as we're going to
     output relocation(s) against it.  */
  /* FIXME: when replacing a relocation, the previous symbol is already
     marked as being used, possibly no longer after its replacement.  */
  if (relocSymP)
    Symbol_MarkToOutput (relocSymP);
}


void *
Reloc_GetRawRelocData (Reloc_State_t *stateP)
{
  if (stateP->numRelocsInt == 0)
    return NULL;
  assert (stateP->raw.rawP == NULL);
  if ((stateP->raw.rawP = malloc (Reloc_GetRawRelocSize (stateP))) == NULL)
    Error_OutOfMem ();
  if (option_aof)
    {
      const struct RelocInt *relSrcP = stateP->relocIntP;
      AofReloc *relDstP = stateP->raw.aofP;
      for (size_t idx = 0; idx != stateP->numRelocsInt; ++idx, ++relSrcP, ++relDstP)
	{
	  relDstP->Offset = armword (relSrcP->offset);
	  const Symbol *symP = relSrcP->symP;
	  assert (symP->attr.used >= 0 && (symP->attr.used & ~HOW2_SIDMASK) == 0);
	  uint32_t how = relSrcP->how | symP->attr.used;
	  if ((symP->attr.type & SYMBOL_AREA) == 0)
	    how |= HOW2_SYMBOL;
	  relDstP->How = armword (how);
	}
    }
  else
    {
      const struct RelocInt *relSrcP = stateP->relocIntP;
      Elf32_Rel *relDstP = stateP->raw.elfP;
      for (size_t idx = 0; idx != stateP->numRelocsInt; ++idx, ++relSrcP, ++relDstP)
	{
	  relDstP->r_offset = relSrcP->offset;
	  const Symbol *symP = relSrcP->symP;
	  assert (symP == NULL || (symP->attr.used >= 0 && (symP->attr.used & 0xFF000000u) == 0));
	  relDstP->r_info = ELF32_R_INFO (symP ? symP->attr.used : 0, relSrcP->how);
	}
    }
  return stateP->raw.rawP;
}


/**
 * Converts ARM relocation name into its value.
 * \param ARM relocation name
 * \return UINT32_MAX when relocation name is unknown, otherwise a < 256
 * value being the corresponding relocation value.
 */
static uint32_t
Reloc_GetRelocValue (const char *relocNameP)
{
#if 0
  for (size_t i = 1; i != sizeof (oARMRelocTypes) / sizeof (oARMRelocTypes[0]); ++i)
    assert (strcmp (oARMRelocTypes[i-1].name, oARMRelocTypes[i].name) < 0);
#endif
  /* All ARM relocation names start with "R_ARM_".  */
  if (strncmp (relocNameP, "R_ARM_", sizeof ("R_ARM_")-1))
    return UINT32_MAX;

  size_t low = 0;
  size_t high = sizeof (oARMRelocTypes) / sizeof (oARMRelocTypes[0]) - 1;
  size_t idx = 0;
  do
    {
      const unsigned char c = (unsigned char)relocNameP[idx + sizeof ("R_ARM_")-1];
      if (c == '\0' && oARMRelocTypes[low].name[idx] == '\0')
	return oARMRelocTypes[low].value;

      while (low <= high)
	{
	  size_t mid = low + (high - low) / 2;
	  const unsigned char m = (unsigned char)oARMRelocTypes[mid].name[idx];
	  if (m < c)
	    low = mid + 1;
	  else if (m > c)
	    high = mid - 1;
	  else
	    {
	      size_t lowNew = mid;
	      while (lowNew > low && oARMRelocTypes[lowNew - 1].name[idx] == c)
		--lowNew;
	      low = lowNew;
	      size_t highNew = mid;
	      while (highNew < high && oARMRelocTypes[highNew + 1].name[idx] == c)
		++highNew;
	      high = highNew;
	      break;
	    }
	}
      if (low > high)
	break;
      ++idx;
    } while (1);
  return UINT32_MAX;
}


/**
 * Implements RELOC
 *   RELOC n, <symbol>
 *   RELOC n
 * With ELF : n < 256 or textual ELF relocation name.
 * Gets ignored for non-ELF output.
 */
bool
c_reloc (void)
{
  /* Only do processing during pass two.  */
  if (gPhase != ePassTwo)
    {
      (void) Input_Rest ();
      return false;
    }

  uint32_t relocNum;
  const Value *relocID = Expr_BuildAndEval (ValueInt | ValueSymbol);
  switch (relocID->Tag)
    {
      case ValueInt:
	if (relocID->Data.Int.type == eIntType_PureInt
	    && (unsigned)relocID->Data.Int.i < 256)
	  relocNum = (unsigned)relocID->Data.Int.i;
	else
	  relocNum = UINT32_MAX;
	break;
      case ValueSymbol:
	relocNum = Reloc_GetRelocValue (relocID->Data.Symbol.symbol->str);
	break;
      default:
	relocNum = UINT32_MAX;
	break;
    }
  if (relocNum == UINT32_MAX)
    {
      Error (ErrorError, "Unknown ELF relocation number or name");
      relocNum = 0;
    }

  const Value *relocSymbolValueP;
  Input_SkipWS ();
  if (Input_Match (',', true))
    {
      const Value *relocSymP = Expr_BuildAndEval (ValueSymbol);
      switch (relocSymP->Tag)
	{
	  case ValueSymbol:
	    if (relocSymP->Data.Symbol.offset != 0)
	      Error (ErrorError, "An offset can not be specified");
	    relocSymbolValueP = relocSymP;
	    break;

	  default:
	    Error (ErrorError, "Not a symbol");
	    relocSymbolValueP = NULL;
	    break;
	}
    }
  else
    relocSymbolValueP = NULL;

  if (!option_aof)
    {
      uint32_t relocOffset = areaCurrentSymbol->attr.area->reloc.offsetForExplicitReloc;
      if (relocOffset == UINT32_MAX)
	Error (ErrorError, "Relocation offset can not be determined");
      else
	Reloc_CreateInternal (relocNum, relocOffset, relocSymbolValueP, true);
    }

  return false;
}
