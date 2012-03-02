	AREA	Data, DATA, READONLY

	[ :LNOT: REFERENCE

	=	"\0\10\100\110\01\010\300\362\177"
	=	"\\\\"
	=	"a\abc"
	=	"a\bbc"
	=	"a\fbc"
	=	"a\nbc"
	=	"a\rbc"
	=	"a\tbc"
	=	"a\vbc"
	=	"a\x01\x10\xa0\xff\xC3bc"

	=	">Dbl Quote char "" <"
	=	">Dollar char $$ <"
	=	">Dollar char $ <"	; Results in a failed lookup
	=	">Dollar char $x <"	; Results in a failed lookup
	=	">Dollar char $x. <"	; Results in a failed lookup

	|

	DCB	0x00, 0x08, 0x40, 0x48, 0x01, 0x08, 0xC0, 0xF2, 0x7F
	DCB	0x5c, 0x5c
	DCB	0x61, 0x07, 0x62, 0x63
	DCB	0x61, 0x08, 0x62, 0x63
	DCB	0x61, 0x0c, 0x62, 0x63
	DCB	0x61, 0x0a, 0x62, 0x63
	DCB	0x61, 0x0d, 0x62, 0x63
	DCB	0x61, 0x09, 0x62, 0x63
	DCB	0x61, 0x0b, 0x62, 0x63
	DCB	0x61, 0x01, 0x10, 0xa0, 0xff, 0xc3, 0x62, 0x63

	=	">Dbl Quote char " :CC: :CHR:&22 :CC: " <"
	=	">Dollar char " :CC: :CHR:&24 :CC: " <"
	=	">Dollar char " :CC: :CHR:&24 :CC: " <"
	=	">Dollar char " :CC: :CHR:&24 :CC: "x <"
	=	">Dollar char " :CC: :CHR:&24 :CC: "x. <"

	]

	END
