; Tests CLZ.
; RUNOPT: -CPU=7-A

		AREA |C$$code|, CODE, READONLY

	[ :LNOT: REFERENCE
		CLZ	R0,R1
	|
		DCI	&E16F0F11
	]

		END