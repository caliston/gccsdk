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
#include <stdint.h>
#include <stdlib.h>

#include "area.h"
#include "code.h"
#include "common.h"
#include "error.h"
#include "expr.h"
#include "fix.h"
#include "get.h"
#include "help_cop.h"
#include "input.h"
#include "lit.h"
#include "main.h"
#include "m_fpe.h"
#include "option.h"
#include "phase.h"
#include "put.h"
#include "reloc.h"
#include "value.h"

/**
 * Pre-indexed:
 *   ", [Rx]"
 *   ", [Rx]!"
 *   ", [Rx, #<expression>]"  (not allowed when stack is true)
 *   ", [Rx, #<expression>]!" (not allowed when stack is true)
 * Post-indexed:
 *   ", [Rx], #<expression>"  (not allowed when stack is true)
 *   ", [Rx], {<expression>}" (not allowed when stack is true)
 * Other:
 *   ", =<literal>" (only allowed when literal is true and stack is false)
 *   ", <label>" (not allowed when stack is true)
 * \param literal true when literal need to be supported.
 *
 * Similar to dstmem() @ m_cpumem.c.
 */
void
HelpCop_Addr (ARMWord ir, bool literal, bool stack, bool isThumb)
{
  Input_SkipWS ();
  if (!Input_Match (',', true))
    {
      Error (ErrorError, "Inserting missing comma before address");
      return;
    }

  const ARMWord instrOffset = areaCurrentSymbol->attr.area->curIdx;
  Value value;
  const Value *valP = NULL;
  switch (Input_Look ())
    {
      case '[':
        {
          Input_Skip ();
          ir |= CPLHS_OP (Get_CPUReg ());	/* Base register */
          Input_SkipWS ();
	  bool preIndexed = !Input_Match (']', true);
          bool offValue = false;
	  if (Input_Match (',', true))
	    {			/* either [base,XX] or [base],XX */
	      if (stack)
	        {
	          Error (ErrorError, "Cannot specify both offset and stack type");
	          break;
	        }
	      if (Input_Match ('#', false))
	        {
	          const Value *im = Expr_BuildAndEval (ValueInt);
	          offValue = true;
	          switch (im->Tag)
		    {
		      case ValueInt:
		        ir = Fix_CopOffset (ir, im->Data.Int.i);
		        break;

		      default:
		        Error (ErrorError, "Illegal offset expression");
		        break;
		    }
	          if (!preIndexed)
		    ir |= W_FLAG; /* If postfix, set writeback */
	        }
	      else if (Input_Match ('{', false))
	        {
	          const Value *im = Expr_BuildAndEval (ValueInt);
	          offValue = true;
	          if (im->Tag != ValueInt)
	            Error (ErrorError, "Illegal option value");
	          if (im->Data.Int.i < -128 || im->Data.Int.i > 256)
		    Error (ErrorError, "Option value too large");
	          ir |= (im->Data.Int.i & 0xFF) | U_FLAG;
	          Input_SkipWS ();
		  if (!Input_Match ('}', false))
		    Error (ErrorError, "Missing '}' in option");
	        }
	      else
	        Error (ErrorError, "Coprocessor memory instructions cannot use register offset");
	      Input_SkipWS ();
	    }
          else
	    {			/* cop_reg,[base] if this way */
	      if (preIndexed)
	        Error (ErrorError, "Illegal character '%c' after base", Input_Look ());
	      if (!stack)
	        ir |= U_FLAG; /* changes #-0 to #+0 */
	    }

	  if (preIndexed)
	    {
	      if (!Input_Match (']', true))
	        Error (ErrorError, "Inserting missing ] after address");
	    }
          else if (!stack && !offValue)
	    preIndexed = true; /* make [base] into [base,#0] */
	  if (Input_Match ('!', true))
	    {
	      if (preIndexed || stack)
	        ir |= W_FLAG;
	      else
	        Error (ErrorError, "Writeback is implied with post-index");
	    }
          else if (stack)
	    preIndexed = true; /* [base] in stack context => [base,#0] */
          if (preIndexed)
	    ir |= P_FLAG;
	  break;
	}

      case '=':
	{
	  /* <floating point literal> */
          Input_Skip ();
	  if (CP_GET_NUMBER (ir) != 1) /* FPE coprocessor is 1 (LFM/STM are using coprocessor 2).  */
	    {
	      Error (ErrorError, "Coprocessor data transfer literal not supported");
	      break;
	    }
	  if (!literal)
	    {
	      Error (ErrorError, "You can't store into a constant");
	      break;
	    }
          if (stack)
	    {
	      Error (ErrorError, "Literal cannot be used when stack type is specified");
	      break;
	    }

	  /* This is always pre-increment.  */
	  ir |= P_FLAG;

          Lit_eSize litSize;
	  switch (ir & PRECISION_MEM_MASK)
	    {
	      case PRECISION_MEM_SINGLE:
		litSize = eLitFloat;
		break;

	      case PRECISION_MEM_EXTENDED:
	      case PRECISION_MEM_PACKED:
		Error (ErrorWarning, "Extended and packed not supported for literals; using double");
		ir = (ir & ~PRECISION_MEM_MASK) | PRECISION_MEM_DOUBLE;
		/* Fall through.  */

	      case PRECISION_MEM_DOUBLE:
		litSize = eLitDouble;
		break;

	      default:
		assert (0);
		break;
	    }	  
	  const Value *literalP = Expr_BuildAndEval (ValueFloat | ValueSymbol | ValueCode);
	  if (literalP->Tag == ValueIllegal)
	    Error (ErrorError, "Wrong literal type");
	  else
	    {
	      value = Lit_RegisterFloat (literalP, litSize, eLitAddr5,
	                                 isThumb ? eInstrType_Thumb : eInstrType_ARM);
	      valP = &value;
	    }
	  break;
	}

      default:
	{
	  /* <label> */
          if (stack)
	    {
	      Error (ErrorError, "Address cannot be used when stack type is specified");
	      break;
	    }
	  /* We're dealing with one of the following:
	   *
	   * 1) a PC-relative label : ValueInt (ABS area), ValueAddr or ValueSymbol.
	   * 2) a field in a register-based map : ValueAddr
	   * 3) a label in a register-based area : ValueAddr
	   */

	  /* Whatever happens, this must be a pre-increment.  */
	  ir |= P_FLAG;

	  valP = Expr_BuildAndEval (ValueInt | ValueAddr | ValueSymbol);
	  break;
	}
    }

  if (stack
      && ((ir & 0x800000) == 0 || (ir & 0x200000)))
    {
      int preIndexOffset = (ir & (1<<15)) ? 1 : 0;
      if (ir & (1<<22))
	preIndexOffset += 2;
      if (preIndexOffset == 0)
	preIndexOffset = 4;
      ir |= 3 * preIndexOffset;
    }

  if (gPhase != ePassOne && valP != NULL)
    {
      if (valP->Tag == ValueFloat)
	{
	  /* This can only happen when "LFD Fx, =<constant>" can be turned
	   into MVF/MNF Fx, #<constant>.  */
	  ir = (ir & NV) | DST_OP (GET_DST_OP (ir));
	  switch (ir & PRECISION_MEM_MASK)
	    {
	      case PRECISION_MEM_SINGLE:
		ir |= PRECISION_SINGLE;
		break;

	      case PRECISION_MEM_DOUBLE:
		ir |= PRECISION_DOUBLE;
		break;

	      default:
		assert (!"Extended/packed are not supported");
		break;
	    }

	  ARMWord im;
	  if ((im = FPE_ConvertImmediate (valP->Data.Float.f)) != (ARMWord)-1)
	    ir |= M_MVF | im;
	  else if ((im = FPE_ConvertImmediate (- valP->Data.Float.f)) != (ARMWord)-1)
	    ir |= M_MNF | im;
	  else
	    assert (0);
	  valP = NULL;
	}

      if (valP != NULL)
        {
	  const RelocAndAddend_t relocAddend = Reloc_SplitRelocAndAddend (valP,
									  areaCurrentSymbol,
									  instrOffset,
	                                                                  false);
	  valP = &relocAddend.addend;

	  bool isPCrel;
	  if (valP->Tag == ValueAddr)
	    {
	      ir |= CPLHS_OP (valP->Data.Addr.r);
	      ir = Fix_CopOffset (ir, valP->Data.Addr.i);
	      isPCrel = valP->Data.Addr.r == 15;
	    }
	  else
	    {
	      Error (ErrorError, "Illegal expression");
	      isPCrel = true;
	    }
	  if (relocAddend.relocSymbol.Tag == ValueSymbol)
	    {
	      if (isThumb)
		Error (ErrorError, "Thumb instruction doesn't support relocation");

	      assert ((ir & P_FLAG) && "Calling reloc for non pre-increment instructions ?");
	      uint32_t aofHow = HOW2_INIT | HOW2_INSTR_UNLIM | (isPCrel ? HOW2_RELATIVE : HOW2_BASED);
	      Reloc_CreateAOF (aofHow, instrOffset, &relocAddend.relocSymbol);
	      uint32_t elfHow;
	      elfHow = isPCrel ? R_ARM_LDC_PC_G0 : R_ARM_LDC_SB_G0;
	      Reloc_CreateELF (elfHow, instrOffset, &relocAddend.relocSymbol);
	    }
	}
    }

  if (isThumb && (ir & P_FLAG) == 0 && CP_GET_LHS(ir) == 15)
    Error (ErrorWarning, "The use of PC as base register in unindexed form is UNPREDICTABLE in Thumb mode");

  Put_Ins (4, ir);
}
