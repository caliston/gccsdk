;----------------------------------------------------------------------------
;
; $Source$
; $Date$
; $Revision$
; $State$
; $Author$
;
;----------------------------------------------------------------------------

        GET     clib/unixlib/asm_dec.s

	AREA	|C$$code|, CODE, READONLY
	
	;Gets the __riscosify_control value which can be defined by
	;the global variable __riscosify_control in the user program.
	;Returns 0 (= default value) when not defined.
	;
	;int __get_riscosify_control (void)
	IMPORT	|__riscosify_control|, WEAK
	EXPORT	|__get_riscosify_control|
	NAME	"__get_riscosify_control"
|__get_riscosify_control|
	LDR	a1, =|__riscosify_control|
	TEQ	a1, #0
	LDRNE	a1, [a1, #0]
	return	AL, pc, lr
