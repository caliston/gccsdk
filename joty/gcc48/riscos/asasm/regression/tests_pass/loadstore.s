; -RUNOPT: -CPU=7-A

		AREA |C$$code|, CODE, READONLY

	[ :LNOT: REFERENCE
		LDR	R0, [R1]
		LDR	R0, [R1, #0]
		LDR	R0, [R1, #4]
		LDR	R0, [R1, R2]
		LDR	R0, [R1], #4
		LDR	R0, [R1], R2

		LDRB	R0, [R1]
		LDRB	R0, [R1, #0]
		LDRB	R0, [R1, #4]
		LDRB	R0, [R1, R2]
		LDRB	R0, [R1], #4
		LDRB	R0, [R1], R2

		LDRH	R0, [R1]
		LDRH	R0, [R1, #0]
		LDRH	R0, [R1, #4]
		LDRH	R0, [R1, R2]
		LDRH	R0, [R1], #4
		LDRH	R0, [R1], R2

		LDRSB	R0, [R1]
		LDRSB	R0, [R1, #0]
		LDRSB	R0, [R1, #4]
		LDRSB	R0, [R1, R2]
		LDRSB	R0, [R1], #4
		LDRSB	R0, [R1], R2

		LDRSH	R0, [R1]
		LDRSH	R0, [R1, #0]
		LDRSH	R0, [R1, #4]
		LDRSH	R0, [R1, R2]
		LDRSH	R0, [R1], #4
		LDRSH	R0, [R1], R2
	|
		DCI	&E5910000
		DCI	&E5910000
		DCI	&E5910004
		DCI	&E7910002
		DCI	&E4910004
		DCI	&E6910002

		DCI	&E5D10000
		DCI	&E5D10000
		DCI	&E5D10004
		DCI	&E7D10002
		DCI	&E4D10004
		DCI	&E6D10002

		DCI	&E1D100B0
		DCI	&E1D100B0
		DCI	&E1D100B4
		DCI	&E19100B2
		DCI	&E0D100B4
		DCI	&E09100B2

		DCI	&E1D100D0
		DCI	&E1D100D0
		DCI	&E1D100D4
		DCI	&E19100D2
		DCI	&E0D100D4
		DCI	&E09100D2

		DCI	&E1D100F0
		DCI	&E1D100F0
		DCI	&E1D100F4
		DCI	&E19100F2
		DCI	&E0D100F4
		DCI	&E09100F2
	]

		END
