/*
 * AsAsm an assembler for ARM
 * Copyright (c) 2012-2013 GCCSDK Developers
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

#include "area.h"
#include "code.h"
#include "include.h"
#include "input.h"
#include "it.h"
#include "error.h"
#include "filestack.h"
#include "local.h"
#include "opt.h"
#include "output.h"
#include "macros.h"
#include "phase.h"
#include "predef_reg.h"
#include "state.h"
#include "symbol.h"
#include "variables.h"

Phase_e gPhase = eStartUp;

/**
 * Broadcast the fact new phase is about to begin.
 */
void
Phase_PrepareFor (Phase_e phase)
{
  Area_PrepareForPhase (phase);
  Code_PrepareForPhase (phase);
  Include_PrepareForPhase (phase);
  Input_PrepareForPhase (phase);
  IT_PrepareForPhase (phase);
  Error_PrepareForPhase (phase);
  FS_PrepareForPhase (phase);
  Local_PrepareForPhase (phase);
  Macro_PrepareForPhase (phase);
  Opt_PrepareForPhase (phase);
  Output_PrepareForPhase (phase);
  PreDefReg_PrepareForPhase (phase);
  State_PrepareForPhase (phase);
  Symbol_PrepareForPhase (phase);
  Var_PrepareForPhase (phase);

  gPhase = phase;
}
