/* Configuration for GNU C-compiler for hosting on Windows NT.
   using a unix style C library.
   Copyright (C) 1995, 1996, 1997, 1998, 1999 Free Software Foundation, Inc.

This file is part of GNU CC.

GNU CC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU CC; see the file COPYING.  If not, write to
the Free Software Foundation, 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA. */

#define EXECUTABLE_SUFFIX ".exe"
#define NO_SYS_SIGLIST 1

/* We support both "/" and "\" since everybody tests both but we
   default to "/".  This is important because if gcc produces Win32
   paths containing backslashes, make and configure may treat the
   backslashes as escape characters.  Many Win32 programs use forward
   slashes so using a forward slash shouldn't be problematic from the
   perspective of wanting gcc to produce native Win32 paths. */
#define DIR_SEPARATOR '/'
#define DIR_SEPARATOR_2 '\\'

/* Convert win32 style path lists to POSIX style for consistency. */ 
#undef GET_ENV_PATH_LIST
#define GET_ENV_PATH_LIST(VAR,NAME)					\
do {									\
  char *_epath;								\
  char *_posixepath;							\
  _epath = _posixepath = getenv (NAME);					\
  /* if we have a posix path list, convert to posix path list */	\
  if (_epath != NULL && *_epath != 0					\
      && ! cygwin_posix_path_list_p (_epath))				\
    {									\
      char *p;								\
      _posixepath = (char *) xmalloc					\
	(cygwin_win32_to_posix_path_list_buf_size (_epath));		\
      cygwin_win32_to_posix_path_list (_epath, _posixepath);		\
    }									\
  (VAR) = _posixepath;							\
} while (0)


/* This is needed so that protoize will compile.  */
#ifndef POSIX
#define POSIX
#endif


/* NAB FIXME: These decls (copied from xm-riscos.h) do not belong
   in here.  */


/* #defines that need visibility everywhere.  */
#define FALSE 0
#define TRUE 1

/* This describes the machine the compiler is hosted on.  */
#define HOST_BITS_PER_CHAR 8
#define HOST_BITS_PER_SHORT 16
#define HOST_BITS_PER_INT 32
#define HOST_BITS_PER_LONG 32
#define HOST_BITS_PER_LONGLONG 64

/* A code distinguishing the floating point format of the host
   machine.  There are three defined values: IEEE_FLOAT_FORMAT,
   VAX_FLOAT_FORMAT, and UNKNOWN_FLOAT_FORMAT.  */

#define HOST_FLOAT_FORMAT IEEE_FLOAT_FORMAT

#define HOST_FLOAT_WORDS_BIG_ENDIAN 1

/* If not compiled with GNU C, use C alloca.  */
#ifndef __GNUC__
#define USE_C_ALLOCA
#endif

/* Define this to be 1 if you know the host compiler supports prototypes, even
   if it doesn't define __STDC__, or define it to be 0 if you do not want any
   prototypes when compiling GNU CC. */
#define USE_PROTOTYPES 1

/* target machine dependencies.
   tm.h is a symbolic link to the actual target specific file.  */
#include "tm.h"

/* Arguments to use with `exit'.  */
#define SUCCESS_EXIT_CODE 0
#define FATAL_EXIT_CODE 33

/* If we have defined POSIX, but are compiling in the BSD environment, then
   we need to define getcwd in terms of getwd.  */
#if defined (POSIX) && defined (_BSD_C)
#define HAVE_GETWD 1
#endif
