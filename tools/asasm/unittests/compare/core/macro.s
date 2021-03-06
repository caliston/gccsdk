; Test basic macro support when using IF/WHILE

	AREA	Data, DATA

	[ :LNOT: REFERENCE
		MACRO
		Test	$stop1, $stop2
		LCLA	loopOut
		WHILE	{TRUE}
			IF	loopOut >= $stop1
				MEXIT
			ENDIF
			LCLA	loopIn
			WHILE	loopIn	< $stop2
				DCB	65 + loopIn
loopIn				SETA	1 + loopIn
			WEND
loopOut			SETA	loopOut + 1
		WEND
		MEND

		= "Test1\n  "
		Test	2, 3
		= "\nTest2\n  "
		Test	3, 2
		= "\nTest3\n  "
		Test	1, 0
		= "\nTest4\n  "
		Test	0, 1
		= "\n"
	|
		= "Test1\n"
		= "  ABCABC\n"
		= "Test2\n"
		= "  ABABAB\n"
		= "Test3\n"
		= "  \n"
		= "Test4\n"
		= "  \n"
	]

; Tests if the presence of a 'comment' doesn't confuse the macro implementation
; (including the local variable handling)

	[ :LNOT: REFERENCE
	MACRO				; comment
$label	TWOTIMES	$val		; comment
	LCLA		tt		; comment
tt	SETA		$val<<1		; comment
$label	&		tt		; comment
	MEND				; comment

twenty	TWOTIMES	10		; comment
	|
twenty	&	20
	]

; Tests if macro name sharing the begin characters of existing mnemonics
; get recognised correctly.

	[ :LNOT: REFERENCE
	; "INC" shares begin chars of "INCBIN" and "INCLUDE".
	MACRO
	INC
	DCD	42
	MEND
	INC
	|
	DCD	42
	]

	[ :LNOT: REFERENCE
	; "GBL" shares begin chars of "GBLA", "GBLS" and "GBLL".
	MACRO
	GBL
	DCD	5
	MEND
	GBL
	|
	DCD	5
	]

; Tests if global & local labels are treated well.
	AREA	Code10, CODE, READONLY
	[ :LNOT: REFERENCE
	MACRO
$label	Test10
	MOV	r7, #7
$label	MOV	r8, #8
	MEND

20	Test10
	B	%BA20
Foo	Test10
	B	Foo
	|
	MOV	r7, #7
	MOV	r8, #8
	B	{PC} - 4
	MOV	r7, #7
Foo	MOV	r8, #8
	B	Foo
	]

	AREA	Code11, CODE
	[ :LNOT: REFERENCE
	MACRO
$label	Test11
	MOV	r0, #1
Doh	ROUT
$label
	B %ba$label
	MEND

20Doh	Test11
	|
	MOV	r0, #1
	B	{PC}
	]

	; Macro name can be bracketed with one or more bar characters.
	AREA	Code12, CODE
	[ :LNOT: REFERENCE
	MACRO
	|Test12a|		; Macro name is Test12a
	MOV	r0, #12
	MEND

	MACRO
	|.Test12b|		; Macro name is .Test12b
	MOV	r1, #12
	MEND

	MACRO
	||.Test12c||		; Macro name is .Test12c
	MOV	r2, #12
	MEND

	MACRO
	|ADD|			; Bars needed for instruction mnemonics & directives.
	MOV	r3, #12
	MEND

	MACRO
	||SUB||			; Bars needed for instruction mnemonics & directives.
	MOV	r4, #12
	MEND

	MACRO
	|INFO|			; Bars needed for instruction mnemonics & directives.
	MOV	r5, #12
	MEND

	MACRO
	||ASSERT||		; Bars needed for instruction mnemonics & directives.
	MOV	r6, #12
	MEND

	Test12a
	|Test12a|
	||Test12a||

	|.Test12b|
	||.Test12b||

	|.Test12c|
	||.Test12c||

	|ADD|			; Calls macro ADD, not instruction mnemonic ADD.
	||ADD||

	|SUB|			; Calls macro SUB, not instruction mnemonic SUB.
	||SUB||

	|INFO|			; Calls macro INFO, not directive INFO.
	||INFO||

	|ASSERT|		; Calls macro ASSERT, not directive ASSERT.
	||ASSERT||

	|
	MOV	r0, #12
	MOV	r0, #12
	MOV	r0, #12

	MOV	r1, #12
	MOV	r1, #12

	MOV	r2, #12
	MOV	r2, #12

	MOV	r3, #12
	MOV	r3, #12

	MOV	r4, #12
	MOV	r4, #12

	MOV	r5, #12
	MOV	r5, #12

	MOV	r6, #12
	MOV	r6, #12
	]

	END
