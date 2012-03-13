@ Stub routines for linking with the SharedCLibrary
@ Copyright (c) 2003-2010 UnixLib Developers

@ Only suited for APCS-32 linking (SharedCLibrary 5) with code compiled
@ with GCCSDK 4.x.

#include "internal/elf-macros.s"
#include "internal/scl-macros.s"

	.text

	NAME	signbit
	DefSCLFncB signbit

	AND	a1, a1, #0x80000000
	MOV	pc, lr

	DefSCLFncE signbit

	DefSCLFncAlias signbitf signbit
	DefSCLFncAlias signbitl signbit

	.end