;----------------------------------------------------------------------------
;
; $Source: /usr/local/cvsroot/gccsdk/unixlib/source/math-asm/_isnan.s,v $
; $Date: 2000/07/15 14:52:24 $
; $Revision: 1.1.1.1 $
; $State: Exp $
; $Author: nick $
;
;----------------------------------------------------------------------------

	GET	clib/unixlib/asm_dec.s

	AREA	|C$$code|,CODE,READONLY

	EXPORT	isnan
isnan
	BIC	a1, a1, #&80000000
	RSB	a3, a2, #0
	ORR	a2, a2, a3
	ORR	a2, a1, a2, LSR #31
	RSB	a1, a2, #&0ff00000
	ADD	a1, a1, #&70000000
	MOV	a1, a1, LSR #31
	return	AL, pc, lr

	END
