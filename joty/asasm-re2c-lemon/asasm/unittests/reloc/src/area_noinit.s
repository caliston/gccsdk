; Tests DATA area with NOINIT.

	AREA BSS1, DATA, NOINIT

	AREA BSS2, DATA, NOINIT
	DCB 0
	DCW 0
	DCD 0

	AREA BSS3, DATA, NOINIT
	= "\0\0\0", 0

	AREA BSS4, DATA, NOINIT
	DCB 0
	ALIGN 64, 5

	AREA BSS5, DATA, NOINIT
	FILL 64, 0, 2
	% 32

	END

