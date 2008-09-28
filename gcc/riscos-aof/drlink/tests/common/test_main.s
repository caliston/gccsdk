OS_WriteC	EQU	0
OS_WriteS	EQU	1
OS_Write0	EQU	2
OS_NewLine	EQU	3
OS_Exit		EQU	17

	IMPORT	test

	AREA	|asm$$code|, CODE

	ENTRY
	ADR	R0, test
	LDR	R2, [R0]
	; When R2 is 42, this means COMDEF contents has been
	; seen an taken into account.  When R2 is 0, this means
	; that COMDEF has not been seen, nor taken into account.
	; When R2 has a different value, something is really wrong.

	MOV	R0, #0
	LDR	R1, =abex
	TEQ	R2, #42
	MOVEQ	R2, #0
	MOVNE	R2, #1
	SWI	OS_Exit
abex
	DCD	&58454241

	END
