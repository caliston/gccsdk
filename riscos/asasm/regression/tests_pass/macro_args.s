; Test the macro argument support.

	AREA	Code, CODE, READONLY

	; Test basic support using a well known macro:
	[ :LNOT: REFERENCE
	MACRO
$Lab	DivMod $Div,$Top,$Bot,$Temp
	ASSERT $Top <> $Bot
	ASSERT $Top <> $Temp
	ASSERT $Bot <> $Temp
	IF	"$Div" <> ""
		ASSERT $Div <> $Top
		ASSERT $Div <> $Bot
		ASSERT $Div <> $Temp
	ENDIF
$Lab
	MOV	$Temp, $Bot
	CMP	$Temp, $Top, LSR #1
90	MOVLS	$Temp, $Temp, LSL #1
	CMP	$Temp, $Top, LSR #1
	BLS	%b90
	IF	"$Div" <> ""
		MOV	$Div, #0
	ENDIF
91	CMP	$Top, $Temp
	SUBCS	$Top, $Top, $Temp
	IF	"$Div" <> ""
		ADC	$Div, $Div, $Div
	ENDIF
	MOV	$Temp, $Temp, LSR #1
	CMP	$Temp, $Bot
	BHS	%b91
	MEND

ratio	DivMod	r0,r5,r4,r2

	|

ratio	MOV	r2, r4
	CMP	r2, r5, LSR #1
90	MOVLS	r2, r2, LSL #1
	CMP	r2, r5, LSR #1
	BLS	%b90
	MOV	r0, #0
91	CMP	r5, r2
	SUBCS	r5, r5, r2
	ADC	r0, r0, r0
	MOV	r2, r2, LSR #1
	CMP	r2, r4
	BHS	%b91

	]

	; Test '.' support in macro argument expansion.
	[ :LNOT: REFERENCE
	MACRO
$Lbl	Test1
$Lbl	DCD	1
	B	Tst1
	MEND

Tst1	Test1

	MACRO
$Lbl	Test2
$Lbl.X	DCD	2
	B	Tst2X
	MEND

Tst2	Test2

	|

	DCD	1
	B	{PC} - 4
	DCD	2
	B	{PC} - 4

	]

	; Test the macro default argument value:
	[ :LNOT: REFERENCE

	; Note there are two spaces after "def3" which make that the 3rd
	; argument default value is " def3  "
	MACRO
	Test3	$Arg1  , $Arg2="def2",$Arg3  = def3  
	$Arg1
	DCB	"$Arg2", 1
	DCB	"$Arg3", 2
	ALIGN
	MEND ; End of macro

	Test3
	Test3	,
	Test3	,,
	Test3	DCB "t1arg1",t1arg2  ,    t1arg3
	Test3	DCB "t2arg1","t2arg2" ,   "t2arg3"
	Test3	,|  ,   "t3arg3"
	Test3	,  "t4arg2"  ,   |

	|

	DCD	&0201
	DCD	&0201
	DCD	&0201
	DCB	"t1arg1", "t1arg2", 1, "t1arg3", 2
	ALIGN
	DCB	"t2arg1", "t2arg2", 1, "t2arg3", 2
	ALIGN
	DCB	"", "def2", 1, "t3arg3", 2
	ALIGN
	DCB	"", "t4arg2", 1, " def3  ", 2
	ALIGN

	]

	END
