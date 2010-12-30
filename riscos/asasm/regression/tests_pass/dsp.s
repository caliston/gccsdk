		AREA |C$$code|, CODE, READONLY

		; Enhanced DSP instructions

	[ :LNOT: REFERENCE
		MCRR	p0,0,r0,r1,c0
		MRRC	p0,0,r0,r1,c0

		QADD	R0,R1,R2

		QDADD	R0,R1,R2

		QDSUB	R0,R1,R2

		QSUB	R0,R1,R2
	|
		DCD	&EC410000
		DCD	&EC510000

		DCD	&E1020051

		DCD	&E1420051

		DCD	&E1620051

		DCD	&E1220051
	]

	[ :LNOT: REFERENCE
		SMLABB	R0,R1,R2,R3
		SMLABT	R0,R1,R2,R3
		SMLATB	R0,R1,R2,R3
		SMLATT	R0,R1,R2,R3

		SMLALBB	R0,R1,R2,R3
		SMLALBT	R0,R1,R2,R3
		SMLALTB	R0,R1,R2,R3
		SMLALTT	R0,R1,R2,R3

		SMLAWB	R0,R1,R2,R3
		SMLAWT	R0,R1,R2,R3

		SMULBB	R0,R1,R2
		SMULBT	R0,R1,R2
		SMULTB	R0,R1,R2
		SMULTT	R0,R1,R2

		SMULWB	R0,R1,R2
		SMULWT	R0,R1,R2
	|
		DCD	&E1003281
		DCD	&E10032C1
		DCD	&E10032A1
		DCD	&E10032E1

		DCD	&E1410382
		DCD	&E14103C2
		DCD	&E14103A2
		DCD	&E14103E2

		DCD	&E1203281
		DCD	&E12032C1

		DCD	&E1600281
		DCD	&E16002C1
		DCD	&E16002A1
		DCD	&E16002E1

		DCD	&E12002A1
		DCD	&E12002E1
	]

		; Addressing Mode 3 - Miscellaneous Loads/Stores
	[ :LNOT: REFERENCE
		; 1
		LDRD	R0,[R1]
		LDRD	R0,[R1,#0]
		LDRD	R0,[R1,#4]
		LDRD	R0,[R1,#-4]
		; 2
		LDRD	R0,[R1,R2]
		LDRD	R0,[R1,-R2]
		; 3
		LDRD	R0,[R1]!
		LDRD	R0,[R1,#0]!
		LDRD	R0,[R1,#4]!
		LDRD	R0,[R1,#-4]!
		; 4
		LDRD	R0,[R1,R2]!
		LDRD	R0,[R1,-R2]!
		; 5
		LDRD	R0,[R1],#4
		LDRD	R0,[R1],#-4
		; 6
		LDRD	R0,[R1],R2
		LDRD	R0,[R1],-R2
	|
		DCD	&E1C100D0
		DCD	&E1C100D0
		DCD	&E1C100D4
		DCD	&E14100D4

		DCD	&E18100D2
		DCD	&E10100D2

		DCD	&E1E100D0
		DCD	&E1E100D0
		DCD	&E1E100D4
		DCD	&E16100D4

		DCD	&E1A100D2
		DCD	&E12100D2

		DCD	&E0C100D4
		DCD	&E04100D4

		DCD	&E08100D2
		DCD	&E00100D2
	]

	[ :LNOT: REFERENCE
		; 1
		STRD	R0,[R1]
		STRD	R0,[R1,#0]
		STRD	R0,[R1,#4]
		STRD	R0,[R1,#-4]
		; 2
		STRD	R0,[R1,R2]
		STRD	R0,[R1,-R2]
		; 3
		STRD	R0,[R1]!
		STRD	R0,[R1,#0]!
		STRD	R0,[R1,#4]!
		STRD	R0,[R1,#-4]!
		; 4
		STRD	R0,[R1,R2]!
		STRD	R0,[R1,-R2]!
		; 5
		STRD	R0,[R1],#4
		STRD	R0,[R1],#-4
		; 6
		STRD	R0,[R1],R2
		STRD	R0,[R1],-R2
	|
		DCD	&E1C100F0
		DCD	&E1C100F0
		DCD	&E1C100F4
		DCD	&E14100F4

		DCD	&E18100F2
		DCD	&E10100F2

		DCD	&E1E100F0
		DCD	&E1E100F0
		DCD	&E1E100F4
		DCD	&E16100F4

		DCD	&E1A100F2
		DCD	&E12100F2

		DCD	&E0C100F4
		DCD	&E04100F4

		DCD	&E08100F2
		DCD	&E00100F2
	]

		END
