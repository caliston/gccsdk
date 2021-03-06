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

/* FPE (FPA10/FPA11 and FPASC) support.  */

#include "config.h"

#include <stdint.h>

#include "area.h"
#include "code.h"
#include "error.h"
#include "expr.h"
#include "filestack.h"
#include "fix.h"
#include "get.h"
#include "help_cop.h"
#include "input.h"
#include "m_fpe.h"
#include "option.h"
#include "put.h"
#include "reloc.h"
#include "state.h"
#include "targetcpu.h"
#include "main.h"
#include "value.h"

typedef enum
{
  eFPUsage_Possible,
  eFPUsage_AlreadyUsed,
  eFPUsage_Forbidden
} FPUsage_e;

static FPUsage_e oFPUsage = eFPUsage_Possible;
static const char *oFPUsageFirstUse_FileName = NULL; /**< First usage of FP instruction/directive (file).  */
static unsigned oFPUsageFirstUse_LineNum = 0; /**< First usage of FP instruction/directive (linenumber).  */
static const char *oFPUsageNOFP_FileName = NULL; /**< Place of NOFP (file).  */
static unsigned oFPUsageNOFP_LineNum = 0; /**< Place of NOFP (linenumber).  */

/**
 * \return always return false (so it can be used as tail-call).
 */
static bool
CheckFPUsageIsAllowed (void)
{
  /* Check if FPA instructions are allowed.  This corresponds with testing on
     {TARGET_FPU_SOFTFPA}.  */
  if ((Target_GetFPUFeatures () & (kFPUExt_NoEndianMismatch | kFPUExt_SoftFPA | kFPUExt_SoftVFP | kFPUExt_FPAv1 | kFPUExt_FPAv2 | kFPUExt_VFPv1xD | kFPUExt_VFPv2 | kFPUExt_VFPv3xD)) == kFPUExt_SoftFPA)
    Error (ErrorError, "SoftFPA configuration doesn't allow FPA instructions");

  switch (oFPUsage)
    {
      case eFPUsage_Possible:
	oFPUsage = eFPUsage_AlreadyUsed;
	oFPUsageFirstUse_FileName = FS_GetCurFileName ();
	oFPUsageFirstUse_LineNum = FS_GetCurLineNumber ();
	break;

      case eFPUsage_AlreadyUsed:
	break;
	
      case eFPUsage_Forbidden:
	Error (ErrorError, "FP usage is not allowed");
	Error_Line (oFPUsageNOFP_FileName, oFPUsageNOFP_LineNum, ErrorError, "note: NOFP was mentioned here");
	break;
    }

  if (State_GetInstrType () != eInstrType_ARM)
    Error (ErrorError, "FPA instructions are not supported in Thumb mode");

  return false;
}

/**
 * Called for:
 *   <POW|RPW|POL> {cond} <S|D|E>{P|M|Z} Fd, Fn, <Fm|#value>
 *   <LOG|LGN|EXP|SIN|COS|TAN|ASN|ACS|ATN> {cond}<S|D|E>{P|M|Z} Fd, <Fm|#value>
 * These FPA instructions are always trapped.
 */
static bool
CheckFPUsageIsAllowedAndGiveHWWarning (void)
{
  bool rtrn = CheckFPUsageIsAllowed ();
  if (option_pedantic)
    Error (ErrorWarning, "FPA opcode will never be executed hardware accelerated");
  return rtrn;
}

ARMWord
FPE_ConvertImmediate (ARMFloat d)
{
  if (d == 0.)
    return 8 | 0;
  if (d == 1.)
    return 8 | 1;
  if (d == 2.)
    return 8 | 2;
  if (d == 3.)
    return 8 | 3;
  if (d == 4.)
    return 8 | 4;
  if (d == 5.)
    return 8 | 5;
  if (d == .5)
    return 8 | 6;
  if (d == 10.)
    return 8 | 7;

  return -1;
}

static ARMWord
Fix_ImmFloat (ARMWord ir, ARMFloat im)
{
  static const char op3[] = "Changing \"%s Fx, Fy, #%.1f\" to \"%s Fx, Fy, #%.1f\"";
  static const char op2[] = "Changing \"%s Fx, #%.1f\" to \"%s Fx, #%.1f\"";

  int f = FPE_ConvertImmediate (im);
  if (f != -1)
    return ir | f;

  /* Immediate float constant was illegal, try the inverse.  */
  f = FPE_ConvertImmediate (-im);

  const ARMWord mnemonic = ir & M_FMNEM;
  ir &= ~M_FMNEM;
  const char *m1, *m2, *optype;
  if (f == -1)
    optype = NULL;
  else
    {
      switch (mnemonic)
	{
	  case M_ADF:
	    ir |= M_SUF;
	    optype = op3; m1 = "ADF"; m2 = "SUF";
	    break;

	  case M_SUF:
	    ir |= M_ADF;
	    optype = op3; m1 = "SUF"; m2 = "ADF";
	    break;

	  case M_MVF:
	    ir |= M_MNF;
	    optype = op2; m1 = "MVF"; m2 = "MNF";
	    break;

	  case M_MNF:
	    ir |= M_MVF;
	    optype = op2; m1 = "MNF"; m2 = "MVF";
	    break;

	  case M_CMF & M_FMNEM:
	    ir |= M_CNF;
	    optype = op2; m1 = "CMF"; m2 = "CNF";
	    break;

	  case M_CNF & M_FMNEM:
	    ir |= M_CMF;
	    optype = op2; m1 = "CNF"; m2 = "CMF";
	    break;

	  case (M_CMF | EXCEPTION_BIT) & M_FMNEM:
	    ir |= M_CNF | EXCEPTION_BIT;
	    optype = op2; m1 = "CMFE"; m2 = "CNFE";
	    break;

	  case (M_CNF | EXCEPTION_BIT) & M_FMNEM:
	    ir |= M_CMF | EXCEPTION_BIT;
	    optype = op2; m1 = "CNFE"; m2 = "CMFE";
	    break;

          case M_ABS:
	    ir |= M_ABS;
	    optype = op2; m1 = m2 = "ABS";
	    break;
	    
	  default:
	    optype = NULL;
	    break;
	}
    }

  if (optype == NULL)
    {
      /* Even the inverse cannot be represented.  */
      Error (ErrorError, "Illegal immediate constant %g", im);
      return ir;
    }

  if (option_fussy)
    Error (ErrorInfo, optype, m1, im, m2, -im);

  return ir | f;
}

static ARMWord
getFloatRhs (ARMWord ir)
{
  if (Input_Match ('#', false))
    {
      const Value *im = Expr_BuildAndEval (ValueFloat);
      switch (im->Tag)
	{
	  case ValueFloat:
	    ir = Fix_ImmFloat (ir, im->Data.Float.f);
	    break;

	  default:
	    Error (ErrorError, "Illegal float immediate");
	    break;
	}
    }
  else
    ir |= Get_FPUReg ();

  return ir;
}

/** DATA dyadic **/

static void
dstlhsrhs (ARMWord ir)
{
  unsigned op = Get_FPUReg ();
  ir |= DST_OP (op);
  Input_SkipWS ();
  if (!Input_Match (',', true))
    Error (ErrorError, "%sdst", InsertCommaAfter);
  op = Get_FPUReg ();
  ir |= LHS_OP (op);
  Input_SkipWS ();
  if (!Input_Match (',', true))
    Error (ErrorError, "%slhs", InsertCommaAfter);
  Put_Ins (4, getFloatRhs (ir));
}


/**
 * Implements ADF (add).
 *   Fd := Fn + Fm
 */
bool
m_adf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_ADF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements DVF (divide).
 *   Fd := Fn / Fm
 */
bool
m_dvf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_DVF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements FDV (fast divide).
 *   Fd := Fn / Fm
 */
bool
m_fdv (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  if ((cc & PRECISION_MASK) != PRECISION_SINGLE)
    Error (ErrorWarning, "%s is only defined for single precision use", "FDV");
  dstlhsrhs (M_FDV | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements FML (fast multiply).
 *   Fd := Fn * Fm
 */
bool
m_fml (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  if ((cc & PRECISION_MASK) != PRECISION_SINGLE)
    Error (ErrorWarning, "%s is only defined for single precision use", "FML");
  dstlhsrhs (M_FML | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements FRD (fast reverse divide).
 *   Fd := Fm / Fn 
 */
bool
m_frd (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  if ((cc & PRECISION_MASK) != PRECISION_SINGLE)
    Error (ErrorWarning, "%s is only defined for single precision use", "FRD");
  dstlhsrhs (M_FRD | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements MUF (multiply).
 *   Fd := Fn * Fm 
 */
bool
m_muf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_MUF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements POL (polar angle, arctan2).
 *   Fd := polar angle of (Fn, Fm) 
 */
bool
m_pol (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_POL | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements POW (power).
 *   Fd := Fn raised to the power of Fm 
 */
bool
m_pow (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_POW | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements RDF (reverse divide).
 *   Fd := Fm / Fn 
 */
bool
m_rdf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_RDF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements RMF (remainder).
 *   Fd := IEEE remainder of Fn / Fm 
 */
bool
m_rmf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_RMF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements RPW (reverse power).
 *   Fd := Fm raised to the power of Fn 
 */
bool
m_rpw (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_RPW | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements RSF (reverse subtract).
 *   Fd := Fm - Fn
 */
bool
m_rsf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_RSF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements SUF (subtract).
 *   Fd := Fn - Fm 
 */
bool
m_suf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstlhsrhs (M_SUF | cc);
  return CheckFPUsageIsAllowed ();
}


/** DATA monadic **/

static void
dstrhs (ARMWord ir)
{
  unsigned op = Get_FPUReg ();
  ir |= DST_OP (op);
  Input_SkipWS ();
  if (!Input_Match (',', true))
    Error (ErrorError, "%sdst", InsertCommaAfter);
  Put_Ins (4, getFloatRhs (ir));
}

/**
 * Implements ABS (absolute value).
 *   Fd := ABS ( Fm ) 
 */
bool
m_abs (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_ABS | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements ACS (arc cosine).
 *   Fd := arccosine of Fm
 */
bool
m_acs (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_ACS | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements ASN (arc sine).
 *   Fd := arcsine of Fm
 */
bool
m_asn (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_ASN | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements ATN (arc tanget).
 *   Fd := arctangent of Fm
 */
bool
m_atn (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_ATN | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements COS (cosine).
 *   Fd := cosine of Fm 
 */
bool
m_cos (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_COS | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements EXP (exponent).
 *   Fd := e ** Fm 
 */
bool
m_exp (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_EXP | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements LGN (logarithm to base e).
 *   Fd := ln of Fm 
 */
bool
m_lgn (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_LGN | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements LOG (logarithm to base 10).
 *   Fd := log10 of Fm
 */
bool
m_log (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_LOG | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements MNF (move negated).
 *   Fd := - Fm 
 */
bool
m_mnf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_MNF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements MVF (move).
 *   Fd := Fm 
 */
bool
m_mvf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_MVF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements RND (round to integral value).
 *   Fd := integer value of Fm 
 */
bool
m_rnd (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_RND | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements SIN (sine).
 *   Fd := sine of Fm 
 */
bool
m_sin (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_SIN | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements SQT (square root).
 *   Fd := square root of Fm
 */
bool
m_sqt (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_SQT | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements TAN (tanget).
 *   Fd := tangent of Fm
 */
bool
m_tan (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_TAN | cc);
  return CheckFPUsageIsAllowedAndGiveHWWarning ();
}

/**
 * Implements URD (unnormalized round).
 *   Fd := integer value of Fm, possibly in abnormal form
 */
bool
m_urd (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_URD | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements NRM (normalize).
 *   Fd := normalized form of Fm 
 */
bool
m_nrm (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstrhs (M_NRM | cc);
  return CheckFPUsageIsAllowed ();
}

static void
comparelow (ARMWord ir)		/* No precision and no rounding allowed ? */
{
  ir |= LHS_OP (Get_FPUReg ());
  Input_SkipWS ();
  if (!Input_Match (',', true))
    Error (ErrorError, "%slhs", InsertCommaAfter);
  Put_Ins (4, getFloatRhs (ir));
}

/**
 * Implements CMF/CMFE (compare floating).
 */
bool
m_cmf (bool doLowerCase)
{
  ARMWord cc = Option_ExceptionCond (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  comparelow (M_CMF | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements CNF/CNFE (compare negated floating).
 */
bool
m_cnf (bool doLowerCase)
{
  ARMWord cc = Option_ExceptionCond (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  comparelow (M_CNF | cc);
  return CheckFPUsageIsAllowed ();
}

/** REGISTER TRANSFER **/

/**
 * Implements FIX (convert floating-point to integer).
 *   Rd := Fm
 */
bool
m_fix (bool doLowerCase)
{
  ARMWord cc = Option_CondOptRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;

  ARMWord ir = M_FIX | cc;
  ir |= DST_OP (Get_CPUReg ());
  Input_SkipWS ();
  if (!Input_Match (',', true))
    Error (ErrorError, "%sdst", InsertCommaAfter);
  Put_Ins (4, getFloatRhs (ir));
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements FLT (convert integer to floating-point).
 *   Fn := Rd
 */
bool
m_flt (bool doLowerCase)
{
  ARMWord cc = Option_CondPrecRound (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;

  ARMWord ir = M_FLT | cc;
  ir |= LHS_OP (Get_FPUReg ());
  Input_SkipWS ();
  if (!Input_Match (',', true))
    Error (ErrorError, "%sdst", InsertCommaAfter);
  ir |= DST_OP (Get_CPUReg ());
  Put_Ins (4, ir);
  return CheckFPUsageIsAllowed ();
}

static void
flagtransfer (ARMWord ir)
{
  unsigned op = Get_CPUReg ();
  ir |= DST_OP (op);
  Put_Ins (4, ir);
}

/**
 * Implements WFS (write floating point status register).
 *   FPSR := Rd
 */
bool
m_wfs (bool doLowerCase)
{
  ARMWord cc = Option_Cond (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  flagtransfer (M_WFS | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements RFS (read floating point status register).
 *   Rd := FPSR 
 */
bool
m_rfs (bool doLowerCase)
{
  ARMWord cc = Option_Cond (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  flagtransfer (M_RFS | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements WFC (write floating point control register).
 *   FPCR:= Rd 
 */
bool
m_wfc (bool doLowerCase)
{
  ARMWord cc = Option_Cond (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  flagtransfer (M_WFC | cc);
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements RFC (read floating pointer control register).
 *   Rd := FPCR
 */
bool
m_rfc (bool doLowerCase)
{
  ARMWord cc = Option_Cond (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  flagtransfer (M_RFC | cc);
  return CheckFPUsageIsAllowed ();
}

static void
dstmem (ARMWord ir, bool literal)
{
  ir |= CPDST_OP (Get_FPUReg ());
  HelpCop_Addr (ir, literal, false, false);
}

/**
 * Implements STF.
 */
bool
m_stf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrec_P (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstmem (M_STF | cc, false);
  /* LDFP and STFP are deprecated instructions and are intended for backwards
     compatibility only. These functions are typically implemented by
     appropriate calls to support code.  */
  if ((cc & PRECISION_MEM_MASK) == PRECISION_MEM_PACKED)
    return CheckFPUsageIsAllowedAndGiveHWWarning ();
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements LDF.
 */
bool
m_ldf (bool doLowerCase)
{
  ARMWord cc = Option_CondPrec_P (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  dstmem (M_LDF | cc, true);
  /* LDFP and STFP are deprecated instructions and are intended for backwards
     compatibility only. These functions are typically implemented by
     appropriate calls to support code.  */
  if ((cc & PRECISION_MEM_MASK) == PRECISION_MEM_PACKED)
    return CheckFPUsageIsAllowedAndGiveHWWarning ();
  return CheckFPUsageIsAllowed ();
}


/**
 * Parses the rest of the mnemonic after the "<LFM|SFM>{cond}" part:
 *
 *   <LFM|SFM>{cond} Fd, <count>, [Rn]
 *                                [Rn, #<expression>]{!}
 *                                [Rn],#<expression>
 *   <LFM|SFM>{cond}<FD,EA> Fd, <count>, [Rn]{!}       (stack variant)
 *
 * \return false when rest of the mnemonic gets recognized as part of LFM/SFM.
 * true otherwise (so we can reparse it as macro).
 */
static bool
dstmemx (ARMWord ir, bool doLowerCase)
{
  bool isLoad = (ir & L_FLAG) != 0;
  bool stack = !Input_IsEndOfKeyword ();
  if (stack)
    {
      bool stack_ia;
      const char c1 = Input_Look ();
      const char c2 = Input_LookN (1);
      if (c1 == (doLowerCase ? 'd' : 'D') && c2 == (doLowerCase ? 'b' : 'B'))
	stack_ia = false;
      else if (c1 == (doLowerCase ? 'i' : 'I') && c2 == (doLowerCase ? 'a' : 'A'))
	stack_ia = true;
      else if (c1 == (doLowerCase ? 'e' : 'E') && c2 == (doLowerCase ? 'a' : 'A'))
	stack_ia = !isLoad;
      else if (c1 == (doLowerCase ? 'f' : 'F') && c2 == (doLowerCase ? 'd' : 'D'))
	stack_ia = isLoad;
      else
	return true;
      Input_SkipN (2);
      ir |= stack_ia ? U_FLAG : P_FLAG;
    }
  if (!Input_IsEndOfKeyword ())
    return true;

  Input_SkipWS ();
  ir |= DST_OP (Get_FPUReg ());
  Input_SkipWS ();
  if (!Input_Match (',', false))
    {
      Error (ErrorError, "Inserting comma after dst");
      return false;
    }
  const Value *im = Expr_BuildAndEval (ValueInt);
  if (im->Tag == ValueInt)
    {
      if (im->Data.Int.i < 1 || im->Data.Int.i > 4)
	Error (ErrorError, "Number of fp registers out of range");
    }
  else
    {
      Error (ErrorError, "Illegal %cFM expression", isLoad ? 'L' : 'S');
      return false;
    }
  ir |= (im->Data.Int.i & 1) << 15;
  ir |= (im->Data.Int.i & 2) << (22 - 1);
  HelpCop_Addr (ir, isLoad, stack, false);
  return false;
}

/**
 * Implements SFM.
 */
bool
m_sfm (bool doLowerCase)
{
  ARMWord cc = Option_CondLfmSfm (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  if (dstmemx (M_SFM | cc, doLowerCase))
    return true;
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements LFM.
 */
bool
m_lfm (bool doLowerCase)
{
  ARMWord cc = Option_CondLfmSfm (doLowerCase);
  if (cc == kOption_NotRecognized)
    return true;
  if (dstmemx (M_LFM | cc, doLowerCase))
    return true;
  return CheckFPUsageIsAllowed ();
}

/**
 * Implements NOFP.
 */
bool
c_nofp (void)
{
  if (oFPUsage == eFPUsage_AlreadyUsed)
    {
      Error (ErrorError, "Too late to ban floating point");
      Error_Line (oFPUsageFirstUse_FileName, oFPUsageFirstUse_LineNum, ErrorError, "note: first floating point usage was here");
    }
  else
    {
      oFPUsageNOFP_FileName = FS_GetCurFileName ();
      oFPUsageNOFP_LineNum = FS_GetCurLineNumber ();
      oFPUsage = eFPUsage_Forbidden;
    }

  return false;
}
