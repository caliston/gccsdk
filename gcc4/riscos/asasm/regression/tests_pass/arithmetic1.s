		AREA |C$$code|,CODE,READONLY

		; Addressing Mode 1 - Data processing operands

	[ :LNOT: REFERENCE
		ADC	R0,R1,#0		; 1
		ADC	R0,R1,#4
		ADC	R0,R1,#&FF
		ADC	R0,R1,#&3F0
		ADC	R0,R1,R2		; 2
		ADC	R0,R1,R2,LSL #2		; 3
		ADC	R0,R1,R2,LSL #31
		ADC	R0,R1,R2,LSL R3		; 4
		ADC	R0,R1,R2,LSR #2		; 5
		ADC	R0,R1,R2,LSR #32
		ADC	R0,R1,R2,LSR R3		; 6
		ADC	R0,R1,R2,ASR #2		; 7
		ADC	R0,R1,R2,ASR #32
		ADC	R0,R1,R2,ASR R3		; 8
		ADC	R0,R1,R2,ROR #2		; 9
		ADC	R0,R1,R2,ROR #31
		ADC	R0,R1,R2,ROR R3		; 10
		ADC	R0,R1,R2,RRX		; 11

		ADCS	R0,R1,#0		; 1
		ADCS	R0,R1,#4
		ADCS	R0,R1,#&FF
		ADCS	R0,R1,#&3F0
		ADCS	R0,R1,R2		; 2
		ADCS	R0,R1,R2,LSL #2		; 3
		ADCS	R0,R1,R2,LSL #31
		ADCS	R0,R1,R2,LSL R3		; 4
		ADCS	R0,R1,R2,LSR #2		; 5
		ADCS	R0,R1,R2,LSR #32
		ADCS	R0,R1,R2,LSR R3		; 6
		ADCS	R0,R1,R2,ASR #2		; 7
		ADCS	R0,R1,R2,ASR #32
		ADCS	R0,R1,R2,ASR R3		; 8
		ADCS	R0,R1,R2,ROR #2		; 9
		ADCS	R0,R1,R2,ROR #31
		ADCS	R0,R1,R2,ROR R3		; 10
		ADCS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2A10000
		DCI	&E2A10004
		DCI	&E2A100FF
		DCI	&E2A10E3F
		DCI	&E0A10002
		DCI	&E0A10102
		DCI	&E0A10F82
		DCI	&E0A10312
		DCI	&E0A10122
		DCI	&E0A10022
		DCI	&E0A10332
		DCI	&E0A10142
		DCI	&E0A10042
		DCI	&E0A10352
		DCI	&E0A10162
		DCI	&E0A10FE2
		DCI	&E0A10372
		DCI	&E0A10062

		DCI	&E2B10000
		DCI	&E2B10004
		DCI	&E2B100FF
		DCI	&E2B10E3F
		DCI	&E0B10002
		DCI	&E0B10102
		DCI	&E0B10F82
		DCI	&E0B10312
		DCI	&E0B10122
		DCI	&E0B10022
		DCI	&E0B10332
		DCI	&E0B10142
		DCI	&E0B10042
		DCI	&E0B10352
		DCI	&E0B10162
		DCI	&E0B10FE2
		DCI	&E0B10372
		DCI	&E0B10062
	]

	[ :LNOT: REFERENCE
		ADD	R0,R1,#0		; 1
		ADD	R0,R1,#4
		ADD	R0,R1,#&FF
		ADD	R0,R1,#&3F0
		ADD	R0,R1,R2		; 2
		ADD	R0,R1,R2,LSL #2		; 3
		ADD	R0,R1,R2,LSL #31
		ADD	R0,R1,R2,LSL R3		; 4
		ADD	R0,R1,R2,LSR #2		; 5
		ADD	R0,R1,R2,LSR #32
		ADD	R0,R1,R2,LSR R3		; 6
		ADD	R0,R1,R2,ASR #2		; 7
		ADD	R0,R1,R2,ASR #32
		ADD	R0,R1,R2,ASR R3		; 8
		ADD	R0,R1,R2,ROR #2		; 9
		ADD	R0,R1,R2,ROR #31
		ADD	R0,R1,R2,ROR R3		; 10
		ADD	R0,R1,R2,RRX		; 11

		ADDS	R0,R1,#0		; 1
		ADDS	R0,R1,#4
		ADDS	R0,R1,#&FF
		ADDS	R0,R1,#&3F0
		ADDS	R0,R1,R2		; 2
		ADDS	R0,R1,R2,LSL #2		; 3
		ADDS	R0,R1,R2,LSL #31
		ADDS	R0,R1,R2,LSL R3		; 4
		ADDS	R0,R1,R2,LSR #2		; 5
		ADDS	R0,R1,R2,LSR #32
		ADDS	R0,R1,R2,LSR R3		; 6
		ADDS	R0,R1,R2,ASR #2		; 7
		ADDS	R0,R1,R2,ASR #32
		ADDS	R0,R1,R2,ASR R3		; 8
		ADDS	R0,R1,R2,ROR #2		; 9
		ADDS	R0,R1,R2,ROR #31
		ADDS	R0,R1,R2,ROR R3		; 10
		ADDS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2810000
		DCI	&E2810004
		DCI	&E28100FF
		DCI	&E2810E3F
		DCI	&E0810002
		DCI	&E0810102
		DCI	&E0810F82
		DCI	&E0810312
		DCI	&E0810122
		DCI	&E0810022
		DCI	&E0810332
		DCI	&E0810142
		DCI	&E0810042
		DCI	&E0810352
		DCI	&E0810162
		DCI	&E0810FE2
		DCI	&E0810372
		DCI	&E0810062

		DCI	&E2910000
		DCI	&E2910004
		DCI	&E29100FF
		DCI	&E2910E3F
		DCI	&E0910002
		DCI	&E0910102
		DCI	&E0910F82
		DCI	&E0910312
		DCI	&E0910122
		DCI	&E0910022
		DCI	&E0910332
		DCI	&E0910142
		DCI	&E0910042
		DCI	&E0910352
		DCI	&E0910162
		DCI	&E0910FE2
		DCI	&E0910372
		DCI	&E0910062
	]

	[ :LNOT: REFERENCE
		AND	R0,R1,#0		; 1
		AND	R0,R1,#4
		AND	R0,R1,#&FF
		AND	R0,R1,#&3F0
		AND	R0,R1,R2		; 2
		AND	R0,R1,R2,LSL #2		; 3
		AND	R0,R1,R2,LSL #31
		AND	R0,R1,R2,LSL R3		; 4
		AND	R0,R1,R2,LSR #2		; 5
		AND	R0,R1,R2,LSR #32
		AND	R0,R1,R2,LSR R3		; 6
		AND	R0,R1,R2,ASR #2		; 7
		AND	R0,R1,R2,ASR #32
		AND	R0,R1,R2,ASR R3		; 8
		AND	R0,R1,R2,ROR #2		; 9
		AND	R0,R1,R2,ROR #31
		AND	R0,R1,R2,ROR R3		; 10
		AND	R0,R1,R2,RRX		; 11

		ANDS	R0,R1,#0		; 1
		ANDS	R0,R1,#4
		ANDS	R0,R1,#&FF
		ANDS	R0,R1,#&3F0
		ANDS	R0,R1,R2		; 2
		ANDS	R0,R1,R2,LSL #2		; 3
		ANDS	R0,R1,R2,LSL #31
		ANDS	R0,R1,R2,LSL R3		; 4
		ANDS	R0,R1,R2,LSR #2		; 5
		ANDS	R0,R1,R2,LSR #32
		ANDS	R0,R1,R2,LSR R3		; 6
		ANDS	R0,R1,R2,ASR #2		; 7
		ANDS	R0,R1,R2,ASR #32
		ANDS	R0,R1,R2,ASR R3		; 8
		ANDS	R0,R1,R2,ROR #2		; 9
		ANDS	R0,R1,R2,ROR #31
		ANDS	R0,R1,R2,ROR R3		; 10
		ANDS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2010000
		DCI	&E2010004
		DCI	&E20100FF
		DCI	&E2010E3F
		DCI	&E0010002
		DCI	&E0010102
		DCI	&E0010F82
		DCI	&E0010312
		DCI	&E0010122
		DCI	&E0010022
		DCI	&E0010332
		DCI	&E0010142
		DCI	&E0010042
		DCI	&E0010352
		DCI	&E0010162
		DCI	&E0010FE2
		DCI	&E0010372
		DCI	&E0010062

		DCI	&E2110000
		DCI	&E2110004
		DCI	&E21100FF
		DCI	&E2110E3F
		DCI	&E0110002
		DCI	&E0110102
		DCI	&E0110F82
		DCI	&E0110312
		DCI	&E0110122
		DCI	&E0110022
		DCI	&E0110332
		DCI	&E0110142
		DCI	&E0110042
		DCI	&E0110352
		DCI	&E0110162
		DCI	&E0110FE2
		DCI	&E0110372
		DCI	&E0110062
	]

	[ :LNOT: REFERENCE
		BIC	R0,R1,#0		; 1
		BIC	R0,R1,#4
		BIC	R0,R1,#&FF
		BIC	R0,R1,#&3F0
		BIC	R0,R1,R2		; 2
		BIC	R0,R1,R2,LSL #2		; 3
		BIC	R0,R1,R2,LSL #31
		BIC	R0,R1,R2,LSL R3		; 4
		BIC	R0,R1,R2,LSR #2		; 5
		BIC	R0,R1,R2,LSR #32
		BIC	R0,R1,R2,LSR R3		; 6
		BIC	R0,R1,R2,ASR #2		; 7
		BIC	R0,R1,R2,ASR #32
		BIC	R0,R1,R2,ASR R3		; 8
		BIC	R0,R1,R2,ROR #2		; 9
		BIC	R0,R1,R2,ROR #31
		BIC	R0,R1,R2,ROR R3		; 10
		BIC	R0,R1,R2,RRX		; 11

		BICS	R0,R1,#0		; 1
		BICS	R0,R1,#4
		BICS	R0,R1,#&FF
		BICS	R0,R1,#&3F0
		BICS	R0,R1,R2		; 2
		BICS	R0,R1,R2,LSL #2		; 3
		BICS	R0,R1,R2,LSL #31
		BICS	R0,R1,R2,LSL R3		; 4
		BICS	R0,R1,R2,LSR #2		; 5
		BICS	R0,R1,R2,LSR #32
		BICS	R0,R1,R2,LSR R3		; 6
		BICS	R0,R1,R2,ASR #2		; 7
		BICS	R0,R1,R2,ASR #32
		BICS	R0,R1,R2,ASR R3		; 8
		BICS	R0,R1,R2,ROR #2		; 9
		BICS	R0,R1,R2,ROR #31
		BICS	R0,R1,R2,ROR R3		; 10
		BICS	R0,R1,R2,RRX		; 11
	|
		DCI	&E3C10000
		DCI	&E3C10004
		DCI	&E3C100FF
		DCI	&E3C10E3F
		DCI	&E1C10002
		DCI	&E1C10102
		DCI	&E1C10F82
		DCI	&E1C10312
		DCI	&E1C10122
		DCI	&E1C10022
		DCI	&E1C10332
		DCI	&E1C10142
		DCI	&E1C10042
		DCI	&E1C10352
		DCI	&E1C10162
		DCI	&E1C10FE2
		DCI	&E1C10372
		DCI	&E1C10062

		DCI	&E3D10000
		DCI	&E3D10004
		DCI	&E3D100FF
		DCI	&E3D10E3F
		DCI	&E1D10002
		DCI	&E1D10102
		DCI	&E1D10F82
		DCI	&E1D10312
		DCI	&E1D10122
		DCI	&E1D10022
		DCI	&E1D10332
		DCI	&E1D10142
		DCI	&E1D10042
		DCI	&E1D10352
		DCI	&E1D10162
		DCI	&E1D10FE2
		DCI	&E1D10372
		DCI	&E1D10062
	]

	[ :LNOT: REFERENCE
		CMN	R0,#0			; 1
		CMN	R0,#4
		CMN	R0,#&FF
		CMN	R0,#&3F0
		CMN	R0,R1			; 2
		CMN	R0,R1,LSL #2		; 3
		CMN	R0,R1,LSL #31
		CMN	R0,R1,LSL R2		; 4
		CMN	R0,R1,LSR #2		; 5
		CMN	R0,R1,LSR #32
		CMN	R0,R1,LSR R2		; 6
		CMN	R0,R1,ASR #2		; 7
		CMN	R0,R1,ASR #32
		CMN	R0,R1,ASR R2		; 8
		CMN	R0,R1,ROR #2		; 9
		CMN	R0,R1,ROR #31
		CMN	R0,R1,ROR R2		; 10
		CMN	R0,R1,RRX		; 11
	|
		DCI	&E3700000
		DCI	&E3700004
		DCI	&E37000FF
		DCI	&E3700E3F
		DCI	&E1700001
		DCI	&E1700101
		DCI	&E1700F81
		DCI	&E1700211
		DCI	&E1700121
		DCI	&E1700021
		DCI	&E1700231
		DCI	&E1700141
		DCI	&E1700041
		DCI	&E1700251
		DCI	&E1700161
		DCI	&E1700FE1
		DCI	&E1700271
		DCI	&E1700061
	]

	[ :LNOT: REFERENCE
		CMP	R0,#0			; 1
		CMP	R0,#4
		CMP	R0,#&FF
		CMP	R0,#&3F0
		CMP	R0,R1			; 2
		CMP	R0,R1,LSL #2		; 3
		CMP	R0,R1,LSL #31
		CMP	R0,R1,LSL R2		; 4
		CMP	R0,R1,LSR #2		; 5
		CMP	R0,R1,LSR #32
		CMP	R0,R1,LSR R2		; 6
		CMP	R0,R1,ASR #2		; 7
		CMP	R0,R1,ASR #32
		CMP	R0,R1,ASR R2		; 8
		CMP	R0,R1,ROR #2		; 9
		CMP	R0,R1,ROR #31
		CMP	R0,R1,ROR R2		; 10
		CMP	R0,R1,RRX		; 11
	|
		DCI	&E3500000
		DCI	&E3500004
		DCI	&E35000FF
		DCI	&E3500E3F
		DCI	&E1500001
		DCI	&E1500101
		DCI	&E1500F81
		DCI	&E1500211
		DCI	&E1500121
		DCI	&E1500021
		DCI	&E1500231
		DCI	&E1500141
		DCI	&E1500041
		DCI	&E1500251
		DCI	&E1500161
		DCI	&E1500FE1
		DCI	&E1500271
		DCI	&E1500061
	]

	[ :LNOT: REFERENCE
		EOR	R0,R1,#0		; 1
		EOR	R0,R1,#4
		EOR	R0,R1,#&FF
		EOR	R0,R1,#&3F0
		EOR	R0,R1,R2		; 2
		EOR	R0,R1,R2,LSL #2		; 3
		EOR	R0,R1,R2,LSL #31
		EOR	R0,R1,R2,LSL R3		; 4
		EOR	R0,R1,R2,LSR #2		; 5
		EOR	R0,R1,R2,LSR #32
		EOR	R0,R1,R2,LSR R3		; 6
		EOR	R0,R1,R2,ASR #2		; 7
		EOR	R0,R1,R2,ASR #32
		EOR	R0,R1,R2,ASR R3		; 8
		EOR	R0,R1,R2,ROR #2		; 9
		EOR	R0,R1,R2,ROR #31
		EOR	R0,R1,R2,ROR R3		; 10
		EOR	R0,R1,R2,RRX		; 11

		EORS	R0,R1,#0		; 1
		EORS	R0,R1,#4
		EORS	R0,R1,#&FF
		EORS	R0,R1,#&3F0
		EORS	R0,R1,R2		; 2
		EORS	R0,R1,R2,LSL #2		; 3
		EORS	R0,R1,R2,LSL #31
		EORS	R0,R1,R2,LSL R3		; 4
		EORS	R0,R1,R2,LSR #2		; 5
		EORS	R0,R1,R2,LSR #32
		EORS	R0,R1,R2,LSR R3		; 6
		EORS	R0,R1,R2,ASR #2		; 7
		EORS	R0,R1,R2,ASR #32
		EORS	R0,R1,R2,ASR R3		; 8
		EORS	R0,R1,R2,ROR #2		; 9
		EORS	R0,R1,R2,ROR #31
		EORS	R0,R1,R2,ROR R3		; 10
		EORS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2210000
		DCI	&E2210004
		DCI	&E22100FF
		DCI	&E2210E3F
		DCI	&E0210002
		DCI	&E0210102
		DCI	&E0210F82
		DCI	&E0210312
		DCI	&E0210122
		DCI	&E0210022
		DCI	&E0210332
		DCI	&E0210142
		DCI	&E0210042
		DCI	&E0210352
		DCI	&E0210162
		DCI	&E0210FE2
		DCI	&E0210372
		DCI	&E0210062

		DCI	&E2310000
		DCI	&E2310004
		DCI	&E23100FF
		DCI	&E2310E3F
		DCI	&E0310002
		DCI	&E0310102
		DCI	&E0310F82
		DCI	&E0310312
		DCI	&E0310122
		DCI	&E0310022
		DCI	&E0310332
		DCI	&E0310142
		DCI	&E0310042
		DCI	&E0310352
		DCI	&E0310162
		DCI	&E0310FE2
		DCI	&E0310372
		DCI	&E0310062
	]

	[ :LNOT: REFERENCE
		MOV	R0,#0			; 1
		MOV	R0,#4
		MOV	R0,#&FF
		MOV	R0,#&3F0
		MOV	R0,R1			; 2
		MOV	R0,R1,LSL #2		; 3
		MOV	R0,R1,LSL #31
		MOV	R0,R1,LSL R2		; 4
		MOV	R0,R1,LSR #2		; 5
		MOV	R0,R1,LSR #32
		MOV	R0,R1,LSR R2		; 6
		MOV	R0,R1,ASR #2		; 7
		MOV	R0,R1,ASR #32
		MOV	R0,R1,ASR R2		; 8
		MOV	R0,R1,ROR #2		; 9
		MOV	R0,R1,ROR #31
		MOV	R0,R1,ROR R2		; 10
		MOV	R0,R1,RRX		; 11

		MOVS	R0,#0			; 1
		MOVS	R0,#4
		MOVS	R0,#&FF
		MOVS	R0,#&3F0
		MOVS	R0,R1			; 2
		MOVS	R0,R1,LSL #2		; 3
		MOVS	R0,R1,LSL #31
		MOVS	R0,R1,LSL R2		; 4
		MOVS	R0,R1,LSR #2		; 5
		MOVS	R0,R1,LSR #32
		MOVS	R0,R1,LSR R2		; 6
		MOVS	R0,R1,ASR #2		; 7
		MOVS	R0,R1,ASR #32
		MOVS	R0,R1,ASR R2		; 8
		MOVS	R0,R1,ROR #2		; 9
		MOVS	R0,R1,ROR #31
		MOVS	R0,R1,ROR R2		; 10
		MOVS	R0,R1,RRX		; 11
	|
		DCI	&E3A00000
		DCI	&E3A00004
		DCI	&E3A000FF
		DCI	&E3A00E3F
		DCI	&E1A00001
		DCI	&E1A00101
		DCI	&E1A00F81
		DCI	&E1A00211
		DCI	&E1A00121
		DCI	&E1A00021
		DCI	&E1A00231
		DCI	&E1A00141
		DCI	&E1A00041
		DCI	&E1A00251
		DCI	&E1A00161
		DCI	&E1A00FE1
		DCI	&E1A00271
		DCI	&E1A00061

		DCI	&E3B00000
		DCI	&E3B00004
		DCI	&E3B000FF
		DCI	&E3B00E3F
		DCI	&E1B00001
		DCI	&E1B00101
		DCI	&E1B00F81
		DCI	&E1B00211
		DCI	&E1B00121
		DCI	&E1B00021
		DCI	&E1B00231
		DCI	&E1B00141
		DCI	&E1B00041
		DCI	&E1B00251
		DCI	&E1B00161
		DCI	&E1B00FE1
		DCI	&E1B00271
		DCI	&E1B00061
	]

	[ :LNOT: REFERENCE
		MVN	R0,#0			; 1
		MVN	R0,#4
		MVN	R0,#&FF
		MVN	R0,#&3F0
		MVN	R0,R1			; 2
		MVN	R0,R1,LSL #2		; 3
		MVN	R0,R1,LSL #31
		MVN	R0,R1,LSL R2		; 4
		MVN	R0,R1,LSR #2		; 5
		MVN	R0,R1,LSR #32
		MVN	R0,R1,LSR R2		; 6
		MVN	R0,R1,ASR #2		; 7
		MVN	R0,R1,ASR #32
		MVN	R0,R1,ASR R2		; 8
		MVN	R0,R1,ROR #2		; 9
		MVN	R0,R1,ROR #31
		MVN	R0,R1,ROR R2		; 10
		MVN	R0,R1,RRX		; 11

		MVNS	R0,#0			; 1
		MVNS	R0,#4
		MVNS	R0,#&FF
		MVNS	R0,#&3F0
		MVNS	R0,R1			; 2
		MVNS	R0,R1,LSL #2		; 3
		MVNS	R0,R1,LSL #31
		MVNS	R0,R1,LSL R2		; 4
		MVNS	R0,R1,LSR #2		; 5
		MVNS	R0,R1,LSR #32
		MVNS	R0,R1,LSR R2		; 6
		MVNS	R0,R1,ASR #2		; 7
		MVNS	R0,R1,ASR #32
		MVNS	R0,R1,ASR R2		; 8
		MVNS	R0,R1,ROR #2		; 9
		MVNS	R0,R1,ROR #31
		MVNS	R0,R1,ROR R2		; 10
		MVNS	R0,R1,RRX		; 11
	|
		DCI	&E3E00000
		DCI	&E3E00004
		DCI	&E3E000FF
		DCI	&E3E00E3F
		DCI	&E1E00001
		DCI	&E1E00101
		DCI	&E1E00F81
		DCI	&E1E00211
		DCI	&E1E00121
		DCI	&E1E00021
		DCI	&E1E00231
		DCI	&E1E00141
		DCI	&E1E00041
		DCI	&E1E00251
		DCI	&E1E00161
		DCI	&E1E00FE1
		DCI	&E1E00271
		DCI	&E1E00061

		DCI	&E3F00000
		DCI	&E3F00004
		DCI	&E3F000FF
		DCI	&E3F00E3F
		DCI	&E1F00001
		DCI	&E1F00101
		DCI	&E1F00F81
		DCI	&E1F00211
		DCI	&E1F00121
		DCI	&E1F00021
		DCI	&E1F00231
		DCI	&E1F00141
		DCI	&E1F00041
		DCI	&E1F00251
		DCI	&E1F00161
		DCI	&E1F00FE1
		DCI	&E1F00271
		DCI	&E1F00061
	]

	[ :LNOT: REFERENCE
		ORR	R0,R1,#0		; 1
		ORR	R0,R1,#4
		ORR	R0,R1,#&FF
		ORR	R0,R1,#&3F0
		ORR	R0,R1,R2		; 2
		ORR	R0,R1,R2,LSL #2		; 3
		ORR	R0,R1,R2,LSL #31
		ORR	R0,R1,R2,LSL R3		; 4
		ORR	R0,R1,R2,LSR #2		; 5
		ORR	R0,R1,R2,LSR #32
		ORR	R0,R1,R2,LSR R3		; 6
		ORR	R0,R1,R2,ASR #2		; 7
		ORR	R0,R1,R2,ASR #32
		ORR	R0,R1,R2,ASR R3		; 8
		ORR	R0,R1,R2,ROR #2		; 9
		ORR	R0,R1,R2,ROR #31
		ORR	R0,R1,R2,ROR R3		; 10
		ORR	R0,R1,R2,RRX		; 11

		ORRS	R0,R1,#0		; 1
		ORRS	R0,R1,#4
		ORRS	R0,R1,#&FF
		ORRS	R0,R1,#&3F0
		ORRS	R0,R1,R2		; 2
		ORRS	R0,R1,R2,LSL #2		; 3
		ORRS	R0,R1,R2,LSL #31
		ORRS	R0,R1,R2,LSL R3		; 4
		ORRS	R0,R1,R2,LSR #2		; 5
		ORRS	R0,R1,R2,LSR #32
		ORRS	R0,R1,R2,LSR R3		; 6
		ORRS	R0,R1,R2,ASR #2		; 7
		ORRS	R0,R1,R2,ASR #32
		ORRS	R0,R1,R2,ASR R3		; 8
		ORRS	R0,R1,R2,ROR #2		; 9
		ORRS	R0,R1,R2,ROR #31
		ORRS	R0,R1,R2,ROR R3		; 10
		ORRS	R0,R1,R2,RRX		; 11
	|
		DCI	&E3810000
		DCI	&E3810004
		DCI	&E38100FF
		DCI	&E3810E3F
		DCI	&E1810002
		DCI	&E1810102
		DCI	&E1810F82
		DCI	&E1810312
		DCI	&E1810122
		DCI	&E1810022
		DCI	&E1810332
		DCI	&E1810142
		DCI	&E1810042
		DCI	&E1810352
		DCI	&E1810162
		DCI	&E1810FE2
		DCI	&E1810372
		DCI	&E1810062

		DCI	&E3910000
		DCI	&E3910004
		DCI	&E39100FF
		DCI	&E3910E3F
		DCI	&E1910002
		DCI	&E1910102
		DCI	&E1910F82
		DCI	&E1910312
		DCI	&E1910122
		DCI	&E1910022
		DCI	&E1910332
		DCI	&E1910142
		DCI	&E1910042
		DCI	&E1910352
		DCI	&E1910162
		DCI	&E1910FE2
		DCI	&E1910372
		DCI	&E1910062
	]

	[ :LNOT: REFERENCE
		RSB	R0,R1,#0		; 1
		RSB	R0,R1,#4
		RSB	R0,R1,#&FF
		RSB	R0,R1,#&3F0
		RSB	R0,R1,R2		; 2
		RSB	R0,R1,R2,LSL #2		; 3
		RSB	R0,R1,R2,LSL #31
		RSB	R0,R1,R2,LSL R3		; 4
		RSB	R0,R1,R2,LSR #2		; 5
		RSB	R0,R1,R2,LSR #32
		RSB	R0,R1,R2,LSR R3		; 6
		RSB	R0,R1,R2,ASR #2		; 7
		RSB	R0,R1,R2,ASR #32
		RSB	R0,R1,R2,ASR R3		; 8
		RSB	R0,R1,R2,ROR #2		; 9
		RSB	R0,R1,R2,ROR #31
		RSB	R0,R1,R2,ROR R3		; 10
		RSB	R0,R1,R2,RRX		; 11

		RSBS	R0,R1,#0		; 1
		RSBS	R0,R1,#4
		RSBS	R0,R1,#&FF
		RSBS	R0,R1,#&3F0
		RSBS	R0,R1,R2		; 2
		RSBS	R0,R1,R2,LSL #2		; 3
		RSBS	R0,R1,R2,LSL #31
		RSBS	R0,R1,R2,LSL R3		; 4
		RSBS	R0,R1,R2,LSR #2		; 5
		RSBS	R0,R1,R2,LSR #32
		RSBS	R0,R1,R2,LSR R3		; 6
		RSBS	R0,R1,R2,ASR #2		; 7
		RSBS	R0,R1,R2,ASR #32
		RSBS	R0,R1,R2,ASR R3		; 8
		RSBS	R0,R1,R2,ROR #2		; 9
		RSBS	R0,R1,R2,ROR #31
		RSBS	R0,R1,R2,ROR R3		; 10
		RSBS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2610000
		DCI	&E2610004
		DCI	&E26100FF
		DCI	&E2610E3F
		DCI	&E0610002
		DCI	&E0610102
		DCI	&E0610F82
		DCI	&E0610312
		DCI	&E0610122
		DCI	&E0610022
		DCI	&E0610332
		DCI	&E0610142
		DCI	&E0610042
		DCI	&E0610352
		DCI	&E0610162
		DCI	&E0610FE2
		DCI	&E0610372
		DCI	&E0610062

		DCI	&E2710000
		DCI	&E2710004
		DCI	&E27100FF
		DCI	&E2710E3F
		DCI	&E0710002
		DCI	&E0710102
		DCI	&E0710F82
		DCI	&E0710312
		DCI	&E0710122
		DCI	&E0710022
		DCI	&E0710332
		DCI	&E0710142
		DCI	&E0710042
		DCI	&E0710352
		DCI	&E0710162
		DCI	&E0710FE2
		DCI	&E0710372
		DCI	&E0710062
	]

	[ :LNOT: REFERENCE
		RSC	R0,R1,#0		; 1
		RSC	R0,R1,#4
		RSC	R0,R1,#&FF
		RSC	R0,R1,#&3F0
		RSC	R0,R1,R2		; 2
		RSC	R0,R1,R2,LSL #2		; 3
		RSC	R0,R1,R2,LSL #31
		RSC	R0,R1,R2,LSL R3		; 4
		RSC	R0,R1,R2,LSR #2		; 5
		RSC	R0,R1,R2,LSR #32
		RSC	R0,R1,R2,LSR R3		; 6
		RSC	R0,R1,R2,ASR #2		; 7
		RSC	R0,R1,R2,ASR #32
		RSC	R0,R1,R2,ASR R3		; 8
		RSC	R0,R1,R2,ROR #2		; 9
		RSC	R0,R1,R2,ROR #31
		RSC	R0,R1,R2,ROR R3		; 10
		RSC	R0,R1,R2,RRX		; 11

		RSCS	R0,R1,#0		; 1
		RSCS	R0,R1,#4
		RSCS	R0,R1,#&FF
		RSCS	R0,R1,#&3F0
		RSCS	R0,R1,R2		; 2
		RSCS	R0,R1,R2,LSL #2		; 3
		RSCS	R0,R1,R2,LSL #31
		RSCS	R0,R1,R2,LSL R3		; 4
		RSCS	R0,R1,R2,LSR #2		; 5
		RSCS	R0,R1,R2,LSR #32
		RSCS	R0,R1,R2,LSR R3		; 6
		RSCS	R0,R1,R2,ASR #2		; 7
		RSCS	R0,R1,R2,ASR #32
		RSCS	R0,R1,R2,ASR R3		; 8
		RSCS	R0,R1,R2,ROR #2		; 9
		RSCS	R0,R1,R2,ROR #31
		RSCS	R0,R1,R2,ROR R3		; 10
		RSCS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2E10000
		DCI	&E2E10004
		DCI	&E2E100FF
		DCI	&E2E10E3F
		DCI	&E0E10002
		DCI	&E0E10102
		DCI	&E0E10F82
		DCI	&E0E10312
		DCI	&E0E10122
		DCI	&E0E10022
		DCI	&E0E10332
		DCI	&E0E10142
		DCI	&E0E10042
		DCI	&E0E10352
		DCI	&E0E10162
		DCI	&E0E10FE2
		DCI	&E0E10372
		DCI	&E0E10062

		DCI	&E2F10000
		DCI	&E2F10004
		DCI	&E2F100FF
		DCI	&E2F10E3F
		DCI	&E0F10002
		DCI	&E0F10102
		DCI	&E0F10F82
		DCI	&E0F10312
		DCI	&E0F10122
		DCI	&E0F10022
		DCI	&E0F10332
		DCI	&E0F10142
		DCI	&E0F10042
		DCI	&E0F10352
		DCI	&E0F10162
		DCI	&E0F10FE2
		DCI	&E0F10372
		DCI	&E0F10062
	]

	[ :LNOT: REFERENCE
		SBC	R0,R1,#0		; 1
		SBC	R0,R1,#4
		SBC	R0,R1,#&FF
		SBC	R0,R1,#&3F0
		SBC	R0,R1,R2		; 2
		SBC	R0,R1,R2,LSL #2		; 3
		SBC	R0,R1,R2,LSL #31
		SBC	R0,R1,R2,LSL R3		; 4
		SBC	R0,R1,R2,LSR #2		; 5
		SBC	R0,R1,R2,LSR #32
		SBC	R0,R1,R2,LSR R3		; 6
		SBC	R0,R1,R2,ASR #2		; 7
		SBC	R0,R1,R2,ASR #32
		SBC	R0,R1,R2,ASR R3		; 8
		SBC	R0,R1,R2,ROR #2		; 9
		SBC	R0,R1,R2,ROR #31
		SBC	R0,R1,R2,ROR R3		; 10
		SBC	R0,R1,R2,RRX		; 11

		SBCS	R0,R1,#0		; 1
		SBCS	R0,R1,#4
		SBCS	R0,R1,#&FF
		SBCS	R0,R1,#&3F0
		SBCS	R0,R1,R2		; 2
		SBCS	R0,R1,R2,LSL #2		; 3
		SBCS	R0,R1,R2,LSL #31
		SBCS	R0,R1,R2,LSL R3		; 4
		SBCS	R0,R1,R2,LSR #2		; 5
		SBCS	R0,R1,R2,LSR #32
		SBCS	R0,R1,R2,LSR R3		; 6
		SBCS	R0,R1,R2,ASR #2		; 7
		SBCS	R0,R1,R2,ASR #32
		SBCS	R0,R1,R2,ASR R3		; 8
		SBCS	R0,R1,R2,ROR #2		; 9
		SBCS	R0,R1,R2,ROR #31
		SBCS	R0,R1,R2,ROR R3		; 10
		SBCS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2C10000
		DCI	&E2C10004
		DCI	&E2C100FF
		DCI	&E2C10E3F
		DCI	&E0C10002
		DCI	&E0C10102
		DCI	&E0C10F82
		DCI	&E0C10312
		DCI	&E0C10122
		DCI	&E0C10022
		DCI	&E0C10332
		DCI	&E0C10142
		DCI	&E0C10042
		DCI	&E0C10352
		DCI	&E0C10162
		DCI	&E0C10FE2
		DCI	&E0C10372
		DCI	&E0C10062

		DCI	&E2D10000
		DCI	&E2D10004
		DCI	&E2D100FF
		DCI	&E2D10E3F
		DCI	&E0D10002
		DCI	&E0D10102
		DCI	&E0D10F82
		DCI	&E0D10312
		DCI	&E0D10122
		DCI	&E0D10022
		DCI	&E0D10332
		DCI	&E0D10142
		DCI	&E0D10042
		DCI	&E0D10352
		DCI	&E0D10162
		DCI	&E0D10FE2
		DCI	&E0D10372
		DCI	&E0D10062
	]

	[ :LNOT: REFERENCE
		SUB	R0,R1,#0		; 1
		SUB	R0,R1,#4
		SUB	R0,R1,#&FF
		SUB	R0,R1,#&3F0
		SUB	R0,R1,R2		; 2
		SUB	R0,R1,R2,LSL #2		; 3
		SUB	R0,R1,R2,LSL #31
		SUB	R0,R1,R2,LSL R3		; 4
		SUB	R0,R1,R2,LSR #2		; 5
		SUB	R0,R1,R2,LSR #32
		SUB	R0,R1,R2,LSR R3		; 6
		SUB	R0,R1,R2,ASR #2		; 7
		SUB	R0,R1,R2,ASR #32
		SUB	R0,R1,R2,ASR R3		; 8
		SUB	R0,R1,R2,ROR #2		; 9
		SUB	R0,R1,R2,ROR #31
		SUB	R0,R1,R2,ROR R3		; 10
		SUB	R0,R1,R2,RRX		; 11

		SUBS	R0,R1,#0		; 1
		SUBS	R0,R1,#4
		SUBS	R0,R1,#&FF
		SUBS	R0,R1,#&3F0
		SUBS	R0,R1,R2		; 2
		SUBS	R0,R1,R2,LSL #2		; 3
		SUBS	R0,R1,R2,LSL #31
		SUBS	R0,R1,R2,LSL R3		; 4
		SUBS	R0,R1,R2,LSR #2		; 5
		SUBS	R0,R1,R2,LSR #32
		SUBS	R0,R1,R2,LSR R3		; 6
		SUBS	R0,R1,R2,ASR #2		; 7
		SUBS	R0,R1,R2,ASR #32
		SUBS	R0,R1,R2,ASR R3		; 8
		SUBS	R0,R1,R2,ROR #2		; 9
		SUBS	R0,R1,R2,ROR #31
		SUBS	R0,R1,R2,ROR R3		; 10
		SUBS	R0,R1,R2,RRX		; 11
	|
		DCI	&E2410000
		DCI	&E2410004
		DCI	&E24100FF
		DCI	&E2410E3F
		DCI	&E0410002
		DCI	&E0410102
		DCI	&E0410F82
		DCI	&E0410312
		DCI	&E0410122
		DCI	&E0410022
		DCI	&E0410332
		DCI	&E0410142
		DCI	&E0410042
		DCI	&E0410352
		DCI	&E0410162
		DCI	&E0410FE2
		DCI	&E0410372
		DCI	&E0410062

		DCI	&E2510000
		DCI	&E2510004
		DCI	&E25100FF
		DCI	&E2510E3F
		DCI	&E0510002
		DCI	&E0510102
		DCI	&E0510F82
		DCI	&E0510312
		DCI	&E0510122
		DCI	&E0510022
		DCI	&E0510332
		DCI	&E0510142
		DCI	&E0510042
		DCI	&E0510352
		DCI	&E0510162
		DCI	&E0510FE2
		DCI	&E0510372
		DCI	&E0510062
	]

	[ :LNOT: REFERENCE
		TEQ	R0,#0			; 1
		TEQ	R0,#4
		TEQ	R0,#&FF
		TEQ	R0,#&3F0
		TEQ	R0,R1			; 2
		TEQ	R0,R1,LSL #2		; 3
		TEQ	R0,R1,LSL #31
		TEQ	R0,R1,LSL R2		; 4
		TEQ	R0,R1,LSR #2		; 5
		TEQ	R0,R1,LSR #32
		TEQ	R0,R1,LSR R2		; 6
		TEQ	R0,R1,ASR #2		; 7
		TEQ	R0,R1,ASR #32
		TEQ	R0,R1,ASR R2		; 8
		TEQ	R0,R1,ROR #2		; 9
		TEQ	R0,R1,ROR #31
		TEQ	R0,R1,ROR R2		; 10
		TEQ	R0,R1,RRX		; 11
	|
		DCI	&E3300000
		DCI	&E3300004
		DCI	&E33000FF
		DCI	&E3300E3F
		DCI	&E1300001
		DCI	&E1300101
		DCI	&E1300F81
		DCI	&E1300211
		DCI	&E1300121
		DCI	&E1300021
		DCI	&E1300231
		DCI	&E1300141
		DCI	&E1300041
		DCI	&E1300251
		DCI	&E1300161
		DCI	&E1300FE1
		DCI	&E1300271
		DCI	&E1300061
	]

	[ :LNOT: REFERENCE
		TST	R0,#0			; 1
		TST	R0,#4
		TST	R0,#&FF
		TST	R0,#&3F0
		TST	R0,R1			; 2
		TST	R0,R1,LSL #2		; 3
		TST	R0,R1,LSL #31
		TST	R0,R1,LSL R2		; 4
		TST	R0,R1,LSR #2		; 5
		TST	R0,R1,LSR #32
		TST	R0,R1,LSR R2		; 6
		TST	R0,R1,ASR #2		; 7
		TST	R0,R1,ASR #32
		TST	R0,R1,ASR R2		; 8
		TST	R0,R1,ROR #2		; 9
		TST	R0,R1,ROR #31
		TST	R0,R1,ROR R2		; 10
		TST	R0,R1,RRX		; 11
	|
		DCI	&E3100000
		DCI	&E3100004
		DCI	&E31000FF
		DCI	&E3100E3F
		DCI	&E1100001
		DCI	&E1100101
		DCI	&E1100F81
		DCI	&E1100211
		DCI	&E1100121
		DCI	&E1100021
		DCI	&E1100231
		DCI	&E1100141
		DCI	&E1100041
		DCI	&E1100251
		DCI	&E1100161
		DCI	&E1100FE1
		DCI	&E1100271
		DCI	&E1100061
	]

		END
