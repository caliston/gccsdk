/*
 * AS an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2002-2010 GCCSDK Developers
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
 * output.h
 */

#ifndef output_header_included
#define output_header_included

#include "global.h"

void outputInit (const char *outfile);
void outputFinish (void);
void outputRemove (void);

void outputAof (void);
void outputElf (void);

extern const char *idfn_text;
#ifdef NO_ELF_SUPPORT
#  define DEFAULT_IDFN "GCCSDK ASASM AOF Assembler " VERSION " (" __DATE__ ")"
#else
#  define DEFAULT_IDFN "GCCSDK ASASM AOF/ELF Assembler " VERSION " (" __DATE__ ")"
#endif

#if defined(WORDS_BIGENDIAN)
ARMWord armword (ARMWord val);
ARMWord ourword (ARMWord val);
#else
#define armword(x) (x)
#define ourword(x) (x)
#endif

#endif
