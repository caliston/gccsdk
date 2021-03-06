	; FIXME: GLOBAL

	; Export symbols from a normal code area.
	AREA	Code1, CODE

	MOV	r0, #0
	EXPORT	Exp11
Exp11	MOV	r0, #1

Exp12	MOV	r0, #2
	EXPORT	Exp12

	; Although Exp11 is exported and could be used to relocate against it, the following does not
	; generate a relocation against Exp11 but against Code1.
	DCD	Exp11

	; Export symbols from absolute area.
	AREA	Code2, CODE, ABS

	MOV	r0, #0
	EXPORT	Exp21
Exp21	MOV	r0, #1

Exp22	MOV	r0, #2
	EXPORT	Exp22

	; Export some symbols which we don't have defined.
	AREA	Code3, CODE

	EXPORT	Exp31Foo
	EXPORT	Exp32Foo

	MOV	r0, #1

	; Export symbols from register based area.
	AREA	Data4, DATA, BASED r3

	DCD	0
	EXPORT	Exp41
Exp41	DCD	1

Exp42	DCD	2
	EXPORT	Exp42

	AREA	Code5, CODE
	; Export multiple labels in one go
	EXPORT	Exp51,Exp52  ,  Exp53     ; Comment
Exp51
Exp52
Exp53

	END
