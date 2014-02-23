		AREA |C$$code|, CODE, READONLY

		; Multiply/Multiply Accumulate

	[ :LNOT: REFERENCE
		SMLAL	R0,R1,R2,R3
		SMLALS	R0,R1,R2,R3

		SMULL	R0,R1,R2,R3
		SMULLS	R0,R1,R2,R3

		UMLAL	R0,R1,R2,R3
		UMLALS	R0,R1,R2,R3

		UMULL	R0,R1,R2,R3
		UMULLS	R0,R1,R2,R3
	|
		DCI	&E0E10392
		DCI	&E0F10392

		DCI	&E0C10392
		DCI	&E0D10392

		DCI	&E0A10392
		DCI	&E0B10392

		DCI	&E0810392
		DCI	&E0910392
	]

		END