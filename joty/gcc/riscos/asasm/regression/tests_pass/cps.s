; Tests CPS

	AREA	Code, CODE

	[ :LNOT: REFERENCE	

	CPS	# 16
	CPS	# 0x1F
	
	CPSIE	, #16
	CPSID	, #16

	CPSIE	iF
	CPSIE	a, #18

	|

	DCD	&f1020010
	DCD	&f102001f
	DCD	&f10a0010
	DCD	&f10e0010
	DCD	&f10800c0
	DCD	&f10a0112

	]

	END