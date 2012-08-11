/*
 * AS an assembler for ARM
 * Copyright (c) 1992 Niklas Röjemo
 * Copyright (c) 2000-2012 GCCSDK Developers
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
 * main.c
 */

#include "config.h"

#include <setjmp.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <ctype.h>
#include <locale.h>
#ifdef HAVE_STDINT_H
#  include <stdint.h>
#elif HAVE_INTTYPES_H
#  include <inttypes.h>
#endif
#ifdef __riscos__
#  include <kernel.h>
#endif

#include "area.h"
#include "asm.h"
#include "common.h"
#include "depend.h"
#include "error.h"
#include "filestack.h"
#include "include.h"
#include "input.h"
#include "main.h"
#include "local.h"
#include "output.h"
#include "phase.h"
#include "predef_reg.h"
#include "state.h"
#include "symbol.h"
#include "targetcpu.h"
#include "variables.h"

jmp_buf asmContinue;
bool asmContinueValid = false;
jmp_buf asmAbort;
bool asmAbortValid = false;

/* AS options :
 */
bool option_abs = false;
int option_aof = -1; /* -1 = option not specified.  */
int option_fussy = 0;
bool option_no_code_gen = false;
bool option_nowarn = false;
int option_pedantic = 0;
int option_throwback = 0;
bool option_uppercase = false;
int option_verbose = 0;

static const char *ObjFileName = NULL;
const char *SourceFileName = NULL;

static Syntax_e oOptionInstrSyntax; /* Set via options --16, --32, --arm, --thumb, --thumbx.  */
static InstrType_e oOptionInstrType; /* Set via options --16, --32, --arm, --thumb, --thumbx.  */
static const char *oOptionInstrSet; /* Non-NULL when oOptionInstrSyntax and oOptionInstrType are set.  */  

/* Default is "3/noropi/norwpi/32bit/swstackcheck/fp/nointerwork/fpa/fpe2/hardfp/nofpregargs".  */
APCS_Version_e gOptionVersionAPCS = eAPCS_v3;
uint32_t gOptionAPCS = APCS_OPT_32BIT | APCS_OPT_SWSTACKCHECK | APCS_OPT_FRAMEPTR | APCS_OPT_FPAENDIAN;

typedef struct
{
  const char *fullOptName;
  size_t minOptNameLen;
  uint32_t bitToMask;
  uint32_t bitToSet;
} APCS_Option_t;

static const APCS_Option_t oAPCSOptions[] =
{
  { "reentrant", sizeof ("reent")-1, APCS_OPT_REENTRANT, APCS_OPT_REENTRANT }, /* reentrant, reentr */
  { "nonreentrant", sizeof ("nonreent")-1, APCS_OPT_REENTRANT, 0 }, /* nonreentrant, nonreentr */
  { "pid", sizeof ("pid")-1, APCS_OPT_REENTRANT, APCS_OPT_REENTRANT }, /* pid */
  { "nopid", sizeof ("nopid")-1, APCS_OPT_REENTRANT, 0 }, /* nopid */
  { "rwpi", sizeof ("rwpi")-1, APCS_OPT_REENTRANT, APCS_OPT_REENTRANT }, /* rwpi */
  { "norwpi", sizeof ("norwpi")-1, APCS_OPT_REENTRANT, 0 }, /* norwpi */

  { "26bit", sizeof ("26")-1, APCS_OPT_32BIT, 0 },
  { "32bit", sizeof ("32")-1, APCS_OPT_32BIT, APCS_OPT_32BIT },

  { "swstackcheck", sizeof ("swst")-1, APCS_OPT_SWSTACKCHECK, APCS_OPT_SWSTACKCHECK },
  { "noswstackcheck", sizeof ("nosw")-1, APCS_OPT_SWSTACKCHECK, 0 },

  { "fpregargs", sizeof ("fpr")-1, APCS_OPT_FPREGARGS, APCS_OPT_FPREGARGS },
  { "nofpregargs", sizeof ("nofpr")-1, APCS_OPT_FPREGARGS, 0 },

  { "fpe3", sizeof ("fpe3")-1, APCS_OPT_FPE3, APCS_OPT_FPE3 },
  { "fpe2", sizeof ("fpe2")-1, APCS_OPT_FPE3, 0 },

  { "fp", sizeof ("fp")-1, APCS_OPT_FRAMEPTR, APCS_OPT_FRAMEPTR },
  { "nofp", sizeof ("nofp")-1, APCS_OPT_FRAMEPTR, 0 },

  { "pic", sizeof ("pic")-1, APCS_OPT_ROPI, APCS_OPT_ROPI },
  { "nopic", sizeof ("nopic")-1, APCS_OPT_ROPI, 0 },
  { "ropi", sizeof ("ropi")-1, APCS_OPT_ROPI, APCS_OPT_ROPI },
  { "noropi", sizeof ("noropi")-1, APCS_OPT_ROPI, 0 },

  { "softfp", sizeof ("softfp")-1, APCS_OPT_SOFTFP, APCS_OPT_SOFTFP },
  { "hardfp", sizeof ("hardfp")-1, APCS_OPT_SOFTFP, 0 },
  
  { "interwork", sizeof ("inter")-1, APCS_OPT_INTERWORK, APCS_OPT_INTERWORK },
  { "nointerwork", sizeof ("nointer")-1, APCS_OPT_INTERWORK, 0 },

  { "fpa", sizeof ("fpa")-1, APCS_OPT_FPAENDIAN, APCS_OPT_FPAENDIAN },
  { "vfp", sizeof ("vfp")-1, APCS_OPT_FPAENDIAN, 0 }
};

/**
 * Parses the APCS option.  When no APCS option has been specified, a NULL
 * value will setup the default APCS value.
 * \return true When option value couldn't be parsed.
 */
static bool
ParseOption_APCS (const char *opt)
{
  if (opt == NULL)
    return false;

  if (!strncasecmp (opt, "none", sizeof ("none")-1))
    {
      gOptionVersionAPCS = eAPCS_None;
      opt += sizeof ("none")-1;
    }
  else
    {
      if (opt[0] == '3')
	{
	  gOptionVersionAPCS = eAPCS_v3;
	  ++opt;
	}
      else if (opt[0] == '/' || opt[0] == '\0')
	gOptionVersionAPCS = eAPCS_Empty;
      else
	{
	  fprintf (stderr, PACKAGE_NAME ": Unknown APCS version %s\n", opt);
	  return true;
	}
      uint32_t bitsSet = 0;
      while (opt[0] == '/')
	{
	  ++opt;
	  const char *slash = strchr (opt, '/');
	  size_t len = slash ? (size_t)(slash - opt) : strlen (opt);
	  size_t i;
	  for (i = 0; i != sizeof (oAPCSOptions)/sizeof (oAPCSOptions[0]); ++i)
	    {
	      if (!strncasecmp (opt, oAPCSOptions[i].fullOptName, len)
		  && len >= oAPCSOptions[i].minOptNameLen)
		{
		  /* This option is selected.  */
		  if ((bitsSet & oAPCSOptions[i].bitToMask) != 0
		      && (gOptionAPCS & oAPCSOptions[i].bitToMask) != oAPCSOptions[i].bitToSet)
		    {
		      fprintf (stderr, PACKAGE_NAME ": Conflicting APCS specifier %.*s with an earlier specifier\n", (int)len, opt);
		      return true;
		    }
		  bitsSet |= oAPCSOptions[i].bitToMask;

		  gOptionAPCS = (gOptionAPCS & ~oAPCSOptions[i].bitToMask) | oAPCSOptions[i].bitToSet;
		  opt += len;
		  break;
		}
	    }
	  if (i == sizeof (oAPCSOptions)/sizeof (oAPCSOptions[0]))
	    {
	      fprintf (stderr, PACKAGE_NAME ": Unknown APCS 3 specifier %.*s\n", (int)len, opt);
	      return true;
	    }
	}
    }
  if (opt[0] != '\0')
    {
      fprintf (stderr, PACKAGE_NAME ": Failed to parse APCS specifier %s\n", opt);
      return true;
    }
  return false;
}

RegNames_e gOptionRegNames;

/**
 * Parses the REGNAMES option.
 */
static bool
ParseOption_RegNames (const char *regnames)
{
  if (regnames == NULL)
    regnames = "callstd";
  if (!strcasecmp (regnames, "none"))
    gOptionRegNames = eNone;
  else if (!strcasecmp (regnames, "callstd"))
    gOptionRegNames = eCallStd;
  else if (!strcasecmp (regnames, "all"))
    gOptionRegNames = eAll;
  else
    return true;
  return false;
}


static void
asasm_help (void)
{
  fprintf (stderr,
	   DEFAULT_IDFN
	   "\n"
	   "Usage: " PACKAGE_NAME " [option]... <asmfile> <objfile>\n"
	   "       " PACKAGE_NAME " [option]... -o <objfile> <asmfile>\n"
	   "\n"
	   "Options:\n"
	   "-o objfile                 Specifies destination AOF/ELF file.\n"
	   "-i<directory>              Search 'directory' for included assembler files.\n"
	   "-PreDefine=<value>         Predefine a value using SETA/SETS/SETL syntax.\n"
	   "-no_code_gen               No output file generated, nor 2nd assembler pass done.\n"
	   "-Uppercase                 Recognise instruction mnemonics in upper case only.\n"
	   "-Pedantic                  Display extra warnings.\n"
	   "-Verbose                   Display progress information.\n"
	   "-Fussy                     Display conversion information.\n"
#ifdef __riscos__
	   "-ThrowBack                 Throwback errors to a text editor.\n"
#endif
	   "-cpu=<target-cpu>          Select ARM CPU to target. Use \"list\" to get a full list.\n"
	   "-fpu=<target-fpu>          Select the target floating-point unit (FPU) architecture. Use \"list\" to get a full list.\n"
	   "-device=<target-device>    Select the CPU and FPU. Use \"list\" to get a full list.\n"
	   "-Depend=<file>             Write 'make' source file dependency information to 'file'.\n"
	   "-Help                      Display this help.\n"
	   "-VERsion                   Display the version number.\n"
           "-NOWarn                    Suppress all warnings.\n"
	   "-From asmfile              Source assembler file (ObjAsm compatibility).\n"
	   "-To objfile                Destination AOF file (ObjAsm compatibility).\n"
	   "-ABSolute                  Accept AAsm source code.\n"
	   "-apcs <APCS options>       Specifies one or more APCS options.\n"
	   "-regnames=none             No predefined registers.\n"
           "         =callstd          Standard set of predefined registers (depending on --apcs option).\n"
           "         =all              Full set of predefined registers.\n"
#ifndef NO_ELF_SUPPORT
	   "-elf                       Output ELF file [default].\n"
#endif
	   "-aof                       Output AOF file.\n"
           "-16                        Start processing Thumb instructions (pre-UAL syntax).\n"
           "-32                        Synonym for -arm.\n"
           "-arm                       Start processing ARM instructions (UAL syntax).\n" 
           "-thumb                     Start processing Thumb instructions (UAL syntax).\n"
           "-thumbx                    Start processing ThumbEE instructions (UAL syntax).\n"
	   "\n");
}

static void
atexit_handler (void)
{
  /* Only remove the output file when there was an error and we actually
     started doing the assembling (i.e. don't remove the output file
     when there was an option error).  */
  if (returnExitStatus () != EXIT_SUCCESS
      && gPhase >= ePassOne)
    Output_Remove ();
}

static void
set_option_aof (int writeaof)
{
  if (option_aof != -1 && option_aof != writeaof)
    {
      fprintf (stderr, PACKAGE_NAME ": Conflicting options aof and elf\n");
      exit (EXIT_FAILURE);
    }
  option_aof = writeaof ? true : false;
}


/**
 * Checks if given argument matches the option and if so, return non-NULL
 * option value.
 */
static const char *
IsOptGetArg (char ***argv, const char *opt, size_t optSize, int *argcP)
{
  const char *arg = **argv;
  /* Skip single and double '-'.  */
  if (*arg == '-')
    {
      ++arg;
      if (*arg == '-')
	++arg;
    }
  if (!strncasecmp (arg, opt, optSize))
    {
      switch (arg[optSize])
	{
	  case '\0':
	    if (--*argcP)
	      return *(++*argv);
	    fprintf (stderr, PACKAGE_NAME ": Missing argument for -%s\n", opt);
	    exit (EXIT_FAILURE);

	  case '=':
	    return &arg[optSize + 1];
	}
    }
  return NULL;
}


int
main (int argc, char **argv)
{
  atexit (atexit_handler);

  setlocale (LC_ALL, "");

#ifdef DEBUG
  setvbuf(stdout, NULL, _IOLBF, 0);
#endif

  argv++;
  if (argc == 1)
    {
      /* No command line arguments supplied. Print help and exit.  */
      asasm_help ();
      return EXIT_SUCCESS;
    }
  /* Analyse the command line */

  unsigned numFileNames = 0;
  const char *fileNames[2];
  const char *apcs = NULL;
  const char *regnames = NULL;
  const char *cpu = NULL;
  const char *fpu = NULL;
  const char *device = NULL;

  const char *val;
  for (argc--; argc; argv++, argc--)
    {
      const char *arg = *argv;
      if (arg[0] != '-')
	{
	  /* This is not an option.  */
	  if (numFileNames == 2)
	    {
	      fprintf (stderr, PACKAGE_NAME ": Too many filenames specified\n");
	      return EXIT_FAILURE;
	    }
	  fileNames[numFileNames++] = arg;
	  continue;
	}
      ++arg;

      /* Accept single & double dash for options.  */
      if (arg[0] == '-')
	++arg;
      
      if ((val = IsOptGetArg (&argv, "PD", sizeof ("PD")-1, &argc)) != NULL
	  || (val = IsOptGetArg (&argv, "PreDefine", sizeof ("PreDefine")-1, &argc)) != NULL)
        {
	  if (Input_AddPredefine (val))
            {
	     fprintf (stderr, PACKAGE_NAME ": Too many predefines\n");
	     return EXIT_FAILURE;
            }
        }
      else if (!strcasecmp (arg, "o") || !strcasecmp (arg, "To"))
	{
	  if (--argc)
	    {
	      if (ObjFileName != NULL)
		{
		  fprintf (stderr, PACKAGE_NAME ": Only one output file allowed\n");
		  return EXIT_FAILURE;
		}
	      ObjFileName = *++argv;
	    }
	  else
	    {
	      fprintf (stderr, PACKAGE_NAME ": Missing filename after -%s\n", arg);
	      return EXIT_FAILURE;
	    }
	}
      else if (!strcasecmp (arg, "no_code_gen"))
	option_no_code_gen = true;
#ifdef __riscos__
      else if (!strcasecmp (arg, "throwback") || !strcasecmp (arg, "tb"))
	option_throwback++;
#endif
      else if (!strcasecmp (arg, "u") || !strcasecmp (arg, "uppercase"))
	option_uppercase = true;
      else if (!strcasecmp (arg, "pedantic") || !strcasecmp (arg, "p"))
	option_pedantic++;
      else if ((val = IsOptGetArg (&argv, "cpu", sizeof ("cpu")-1, &argc)) != NULL)
        {
	  if (cpu != NULL && strcasecmp (cpu, val))
	    {
	      fprintf (stderr, PACKAGE_NAME ": Option %s has already been specified: %s and as %s\n", "cpu", cpu, val);
	      return EXIT_FAILURE;
	    }
	  cpu = val;
	}
      else if ((val = IsOptGetArg (&argv, "fpu", sizeof ("fpu")-1, &argc)) != NULL)
        {
	  if (fpu != NULL && strcasecmp (fpu, val))
	    {
	      fprintf (stderr, PACKAGE_NAME ": Option %s has already been specified: %s and as %s\n", "cpu", fpu, val);
	      return EXIT_FAILURE;
	    }
	  fpu = val;
	}
      else if ((val = IsOptGetArg (&argv, "device", sizeof ("device")-1, &argc)) != NULL)
        {
	  if (device != NULL && strcasecmp (device, val))
	    {
	      fprintf (stderr, PACKAGE_NAME ": Option %s has already been specified: %s and as %s\n", "device", device, val);
	      return EXIT_FAILURE;
	    }
	  device = val;
	}
      else if (!strcasecmp (arg, "verbose") || !strcasecmp (arg, "v"))
	option_verbose++;
      else if (!strcasecmp (arg, "fussy") || !strcasecmp (arg, "f"))
	option_fussy++;
      else if ((val = IsOptGetArg (&argv, "apcs", sizeof ("apcs")-1, &argc)) != NULL)
	{
	  if (apcs != NULL && strcasecmp (apcs, val))
	    {
	      fprintf (stderr, PACKAGE_NAME ": Option %s has already been specified: %s and as %s\n", "apcs", apcs, val);
	      return EXIT_FAILURE;
	    }
	  apcs = val;
	}
      else if ((val = IsOptGetArg (&argv, "regnames", sizeof ("regnames")-1, &argc)) != NULL)
	{
	  if (regnames != NULL && strcasecmp (regnames, val))
	    {
	      fprintf (stderr, PACKAGE_NAME ": Option %s has already been specified: %s and as %s\n", "regnames", regnames, val);
	      return EXIT_FAILURE;
	    }
	  regnames = val;
	}
      else if (arg[0] == 'I' || arg[0] == 'i')
	{
	  const char *inclDir = arg + 1;
	  if (*inclDir == '\0')
	    {
	      if (--argc == 0)
	        {
	          fprintf(stderr, PACKAGE_NAME ": Missing include directory after -%s\n", arg);
	          return EXIT_FAILURE;
	        }
	      inclDir = *++argv;
	    }
	  /* Support comma separated directories.  */
	  while (inclDir)
	    {
	      char *c = strchr (inclDir, ',');
	      if (c)
		*c++ = '\0';
	      Include_Add (inclDir);
	      inclDir = c;
	    }
	}
      else if (!strcasecmp (arg, "version") || !strcasecmp (arg, "ver"))
	{
	  fprintf (stderr,
		   DEFAULT_IDFN "\n"
		   "Copyright (c) 1992-2012 Niklas Röjemo, Darren Salt and GCCSDK Developers\n"
		   "This is free software; see the source for copying conditions.  There is NO\n"
		   "warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n\n");
	  return EXIT_SUCCESS;
	}
      else if (!strcasecmp (arg, "H") || !strcasecmp (arg, "help") || !strcasecmp (arg, "?"))
	{
	  /* We need the `--help' option for gcc's --help -v  */
	  asasm_help ();
	  return EXIT_SUCCESS;
	}
      else if (!strcasecmp (arg, "nowarn") || !strcasecmp (arg, "now"))
	option_nowarn = true;
      else if (!strcasecmp (arg, "From"))
	{
	  if (--argc)
	    {
	      if (SourceFileName != NULL)
	        {
	          fprintf (stderr, PACKAGE_NAME ": Only one input file allowed (%s & %s specified)\n", SourceFileName, *++argv);
	          return EXIT_FAILURE;
	        }
	      SourceFileName = *++argv;
	    }
	  else
	    {
	      fprintf (stderr, PACKAGE_NAME ": Missing filename after -%s\n", arg);
	      return EXIT_FAILURE;
	    }
	}
      else if ((val = IsOptGetArg (&argv, "d", sizeof ("d")-1, &argc)) != NULL
	       || (val = IsOptGetArg (&argv, "Depend", sizeof ("Depend")-1, &argc)) != NULL)
	{
	  if (DependFileName != NULL && strcasecmp (DependFileName, val))
	    {
	      fprintf (stderr, PACKAGE_NAME ": option %s has already been specified: %s and as %s\n", "depend", DependFileName, val);
	      return EXIT_FAILURE;
	    }
	  DependFileName = val;
	}
      else if (!strcasecmp (arg, "absolute") || !strcasecmp (arg, "abs"))
	option_abs = true;
#ifndef NO_ELF_SUPPORT
      else if (!strcasecmp (arg, "elf"))
	set_option_aof (0);
#endif
      else if (!strcasecmp (arg, "aof"))
	set_option_aof (1);
      else if (!strcasecmp (arg, "16"))
	{
	  const InstrType_e wantedType = eInstrType_Thumb;
	  const Syntax_e wantedSyntax = eSyntax_PreUALOnly;
	  if (oOptionInstrSet != NULL)
	    {
	      if (wantedType != oOptionInstrType || wantedSyntax != oOptionInstrSyntax)
		{
		  fprintf (stderr, PACKAGE_NAME ": option %s conflicts with previous given option %s\n", arg, oOptionInstrSet);
		  return EXIT_FAILURE;
		}
	    }
	  oOptionInstrType = wantedType;
	  oOptionInstrSyntax = wantedSyntax;
	  oOptionInstrSet = arg;
	}
      else if (!strcasecmp (arg, "32") || !strcasecmp (arg, "arm"))
	{
	  const InstrType_e wantedType = eInstrType_ARM;
	  const Syntax_e wantedSyntax = eSyntax_Both;
	  if (oOptionInstrSet != NULL)
	    {
	      if (wantedType != oOptionInstrType || wantedSyntax != oOptionInstrSyntax)
		{
		  fprintf (stderr, PACKAGE_NAME ": option %s conflicts with previous given option %s\n", arg, oOptionInstrSet);
		  return EXIT_FAILURE;
		}
	    }
	  oOptionInstrType = wantedType;
	  oOptionInstrSyntax = wantedSyntax;
	  oOptionInstrSet = arg;
	}
      else if (!strcasecmp (arg, "thumb"))
	{
	  const InstrType_e wantedType = eInstrType_Thumb;
	  const Syntax_e wantedSyntax = eSyntax_UALOnly;
	  if (oOptionInstrSet != NULL)
	    {
	      if (wantedType != oOptionInstrType || wantedSyntax != oOptionInstrSyntax)
		{
		  fprintf (stderr, PACKAGE_NAME ": option %s conflicts with previous given option %s\n", arg, oOptionInstrSet);
		  return EXIT_FAILURE;
		}
	    }
	  oOptionInstrType = wantedType;
	  oOptionInstrSyntax = wantedSyntax;
	  oOptionInstrSet = arg;
	}
      else if (!strcasecmp (arg, "thumbx"))
	{
	  const InstrType_e wantedType = eInstrType_ThumbEE;
	  const Syntax_e wantedSyntax = eSyntax_UALOnly;
	  if (oOptionInstrSet != NULL)
	    {
	      if (wantedType != oOptionInstrType || wantedSyntax != oOptionInstrSyntax)
		{
		  fprintf (stderr, PACKAGE_NAME ": option %s conflicts with previous given option %s\n", arg, oOptionInstrSet);
		  return EXIT_FAILURE;
		}
	    }
	  oOptionInstrType = wantedType;
	  oOptionInstrSyntax = wantedSyntax;
	  oOptionInstrSet = arg;
	}
      else if (!strcasecmp (arg, "stamp") || !strcasecmp (arg, "quit"))
	{
	  /* -stamp & -quit are old AAsm/ObjAsm options which we silently
	     ignore.  */
	}
      else
	fprintf (stderr, PACKAGE_NAME ": Unknown option -%s ignored\n", arg);
    }

  if (option_aof == -1)
#ifndef NO_ELF_SUPPORT
    option_aof = 0;
#else
    option_aof = 1;
#endif
	    
  if (Target_SetCPU_FPU_Device (cpu, fpu, device))
    return EXIT_FAILURE;
  if (ParseOption_APCS (apcs))
    return EXIT_FAILURE;
  if (ParseOption_RegNames (regnames))
    return EXIT_FAILURE;
  /* Sanity check --16, --32, --arm, --thumb, --thumbx options for given
     cpu/device options.  */
  InstrType_e wantedType;
  Syntax_e wantedSyntax;
  unsigned cpu_features = Target_GetCPUFeatures ();
  bool canDoARMInstr = (cpu_features & kArchExt_v1) != 0;
  if (oOptionInstrSet != NULL)
    {
      bool canDoThumb = (cpu_features & (kCPUExt_v4T | kCPUExt_v6T2)) != 0;
      bool canDoThumbEE = (cpu_features & kCPUExt_ThumbEE) != 0;
      if ((!canDoARMInstr && oOptionInstrType == eInstrType_ARM)
	  || (!canDoThumb && oOptionInstrType != eInstrType_ARM)
          || (!canDoThumbEE && oOptionInstrType == eInstrType_ThumbEE))
	{
	  fprintf (stderr, PACKAGE_NAME ": option %s conflicts with cpu/device option\n", oOptionInstrSet);
	  return EXIT_FAILURE;
	}

      wantedType = oOptionInstrType;
      wantedSyntax = oOptionInstrSyntax;
    }
  else
    {
      wantedType = canDoARMInstr ? eInstrType_ARM : eInstrType_Thumb;
      wantedSyntax = canDoARMInstr ? eSyntax_Both : eSyntax_UALOnly;
    }
  State_SetCmdLineInstrType (wantedType);
  State_SetCmdLineSyntax (wantedSyntax);
  
  if (ObjFileName == NULL)
    {
      if (numFileNames)
	ObjFileName = fileNames[--numFileNames];
      else
	{
	  fprintf (stderr, PACKAGE_NAME ": No output filename specified\n");
	  return EXIT_FAILURE;
	}
    }
  if (SourceFileName == NULL)
    {
      if (numFileNames)
	SourceFileName = fileNames[--numFileNames];
      else
	{
	  fprintf (stderr, PACKAGE_NAME ": No input filename specified\n");
	  return EXIT_FAILURE;
	}
    }
  if (numFileNames)
    {
      while (numFileNames)
        fprintf (stderr, PACKAGE_NAME ": Specified unused filename: %s\n", fileNames[--numFileNames]);
      return EXIT_FAILURE;
    }
  
  if (setjmp (asmAbort))
    {
      asmAbortValid = false;
      fprintf (stderr, PACKAGE_NAME ": Aborted\n");
      while (gCurPObjP != NULL)
	FS_PopPObject (true);
    }
  else
    {
      asmAbortValid = true;
      PreDefReg_Init ();
      if (option_no_code_gen)
        ASM_Assemble (SourceFileName, true); /* One pass only.  */
      else
	{
	  Output_Init (ObjFileName);

	  /* Do the two pass assembly.  */
	  ASM_Assemble (SourceFileName, false);

	  /* Don't try to output anything when we have assemble errors.  */
	  if (returnExitStatus () == EXIT_SUCCESS)
	    {
	      if (setjmp (asmContinue))
		fprintf (stderr, PACKAGE_NAME ": Error when writing object file '%s'.\n", ObjFileName);
	      else
		{
		  asmContinueValid = true;
		  /* Write the ELF/AOF output.  */
		  Phase_PrepareFor (eOutput);
		  if (returnExitStatus () == EXIT_SUCCESS)
		    {
#ifndef NO_ELF_SUPPORT
		      if (!option_aof)
			Output_ELF ();
		      else
#endif
			Output_AOF ();
		    }
		}
	      asmContinueValid = false;
	    }
	}
    }
  Output_Finish ();
  errorFinish ();
  return returnExitStatus ();
}