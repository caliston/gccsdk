;----------------------------------------------------------------------------
;
; $Source: /usr/local/cvsroot/gccsdk/unixlib/source/sys/_os.s,v $
; $Date: 2002/09/24 21:02:38 $
; $Revision: 1.5 $
; $State: Exp $
; $Author: admin $
;
;----------------------------------------------------------------------------

	GET	clib/unixlib/asm_dec.s

	AREA	|C$$code|, CODE, READONLY

	EXPORT	|__os_console|
	NAME	__os_console
|__os_console|
	; Set operating system output stream to the console only
	MOV	a1, #3
	MOV	a2, #0
	SWI	XOS_Byte
	MOVVC	a1, #0
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_vdu|
	NAME	__os_vdu
|__os_vdu|
	SWI	XOS_WriteC
	return	VC, pc, lr
	MVN	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_get|
	NAME	__os_get
|__os_get|
	SWI	XOS_ReadC
	return	VC, pc, lr
	MVN	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_inkey|
	NAME	__os_inkey
|__os_inkey|
	MOV	ip, a1
	MOV	a1, #&81
	AND	a2, ip, #&ff
	MOV	a3, ip, LSR #8
	SWI	XOS_Byte
	MVNVS	a1, #0
	return	VS, pc, lr
	CMP	a3, #0
	MOVEQ	a1, a2
	MVNNE	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_keyflush|
	NAME	__os_keyflush
|__os_keyflush|
	MOV	a1, #21
	MOV	a2, #0
	MOV	a3, #0
	SWI	XOS_Byte
	MOVVC	a1, #0
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_423|
	NAME	__os_423
|__os_423|
	; Enable serial port and keyboard for input
	MOV	a1, #2
	MOV	a2, #2
	SWI	XOS_Byte
	BVS	os_423_l1
	MOV	a1, #0
	MOV	a2, #0	; reset 6551
	MOV	a3, #0
	SWI	XOS_SerialOp
	MOVVC	a1, #0
os_423_l1
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_423vdu|
	NAME	__os_423vdu
|__os_423vdu|
	MOV	a2, a1
	MOV	a1, #3
	SWI	XOS_SerialOp
	MOVVC	a1, #0
	MVNCS	a1, #0	; buffer full
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_423get|
	NAME	__os_423get
|__os_423get|
	MOV	a1, #4
os_423get_l1
	SWI	XOS_SerialOp
	BCS	os_423get_l1
	MOVVC	a1, a2
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_423inkey|
	NAME	__os_423inkey
|__os_423inkey|
	MOV	a4, a1
	SWI	XOS_ReadMonotonicTime
	ADD	a4, a4, a1
os_423inkey_l1
	MOV	a1, #4
	SWI	XOS_SerialOp
	BCC	os_423inkey_l2
	BVS	os_423inkey_l2
	SWI	XOS_ReadMonotonicTime
	CMP	a4, a1
	BHI	os_423inkey_l1
	MVN	a2, #0
os_423inkey_l2
	MOVVC	a1, a2
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_423flush|
	NAME	__os_423flush
|__os_423flush|
	MOV	a1, #21
	MOV	a2, #1
	MOV	a3, #0
	SWI	XOS_Byte
	MOVVC	a1, #0
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_423break|
	NAME	__os_423break
|__os_423break|
	MOV	a2, a1
	MOV	a1, #2
	SWI	XOS_SerialOp
	MOVVC	a1, #0
	MVNVS	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_byte|
	NAME	__os_byte
|__os_byte|
	MOV	ip, a4
	SWI	XOS_Byte
	return	VS, pc, lr
	CMP	ip, #0
	STMNEIA ip, {a1, a2, a3}
	MOV	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_word|
	NAME	__os_word
|__os_word|
	SWI	XOS_Word
	MOVVC	a1, #0
	return	AL, pc, lr

os_prhex_data
	DCB	"    "

	EXPORT	|__os_prhex|
	NAME	__os_prhex
|__os_prhex|
	LDR	a3, os_prhex_data
	MOV	a2, a3
	STMFD	sp!, {a2, a3}	; fill buffer with 8 spaces
	ADD	a3, sp, #8
os_prhex_l1
	AND	a2, a1, #&f
	CMP	a2, #10
	ADDLT	a2, a2, #48
	ADDGE	a2, a2, #87
	STRB	a2, [a3, #-1]!
	MOVS	a1, a1, LSR #4	; Will be 0 when 8 nibbles are written
	BNE	os_prhex_l1	; may be 0 before -> eliminates leading zeros

	MOV	a1, sp
	MOV	a2, #8
	SWI	XOS_WriteN
	MOVVC	a1, #0
	ADD	sp, sp, #8
	return	AL, pc, lr

	; Print out a 32-bit number (passed in a1) as a signed
	; decimal quantity
	EXPORT	|__os_prdec|
	NAME	__os_prdec
|__os_prdec|
	MOV	a3, #16		; allocate a temporary buffer of 16 bytes
	SUB	a2, sp, a3
	SWI	XOS_ConvertInteger4
	SWI	XOS_Write0
	return	AL, pc, lr

	EXPORT	|__os_print|
	NAME	__os_print
|__os_print|
	SWI	XOS_Write0
	MOVVC	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_nl|
	NAME	__os_nl
|__os_nl|
	SWI	XOS_NewLine
	MOVVC	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_cli|
	NAME	__os_cli
|__os_cli|
	SWI	XOS_CLI
	MOVVC	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_file|
	NAME	__os_file
|__os_file|
	STMFD	sp!, {v1, v2, lr}
	MOVS	ip, a3
	ADD	a3, a3, #8
	LDMNEIA a3, {a3, a4, v1, v2}
	SWI	XOS_File
	MOVVC	a1, #0
	CMP	ip, #0
	STMNEIA ip, {a1, a2, a3, a4, v1, v2}
	stackreturn	AL, "v1, v2, pc"

	EXPORT	|__os_fopen|
	NAME	__os_fopen
|__os_fopen|
	MOV	ip, a3
	SWI	XOS_Find
	STR	a1, [ip]
	MOVVC	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_fclose|
	NAME	__os_fclose
|__os_fclose|
	MOV	a2, a1
	MOV	a1, #0
	SWI	XOS_Find
	MOVVC	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_fread|
	NAME	__os_fread
|__os_fread|
	STMFD	sp!, {v1, lr}
	MOV	ip, a4
	MOV	a4, a3
	MOV	a3, a2
	MOV	a2, a1
	MOV	a1, #4
	SWI	XOS_GBPB
	MOVVC	a1, #0
	CMP	ip, #0
	STMNEIA	ip, {a1, a2, a3, a4, v1}
	stackreturn	AL, "v1, pc"

	EXPORT	|__os_fwrite|
	NAME	__os_fwrite
|__os_fwrite|
	STMFD	sp!, {v1, lr}
	MOV	ip, a4
	MOV	a4, a3
	MOV	a3, a2
	MOV	a2, a1
	MOV	a1, #2
	SWI	XOS_GBPB
	MOVVC	a1, #0
	CMP	ip, #0
	STMNEIA	ip, {a1, a2, a3, a4, v1}
	stackreturn	AL, "v1, pc"

	EXPORT	|__os_args|
	NAME	__os_args
|__os_args|
	MOV	ip, a4
	SWI	XOS_Args
	MOVVC	a1, #0
	CMP	ip, #0
	STMNEIA	ip, {a1, a2, a3}
	return	AL, pc, lr

	EXPORT	|__os_fsctrl|
	NAME	__os_fsctrl
|__os_fsctrl|
	SWI	XOS_FSControl
	MOVVC	a1, #0
	return	AL, pc, lr

	EXPORT	|__os_swi|
	NAME	__os_swi
|__os_swi|
	STMFD	sp!, {a2, v1, v2, v3, v4, v5, v6, lr}
	ORR	ip, a1, #&20000		; X bit
	TEQ	a2, #0
	LDMNEIA a2, {a1, a2, a3, a4, v1, v2, v3, v4, v5, v6}
	SWI	XOS_CallASWIR12
	LDMFD	sp!, {lr}		; Retrieve passed in a2
	TEQ	lr, #0
	STMNEIA lr, {a1, a2, a3, a4, v1, v2, v3, v4, v5, v6}
	MOVVC	a1, #0
	stackreturn	AL, "v1, v2, v3, v4, v5, v6, pc"

	END
